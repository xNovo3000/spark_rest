import 'dart:io';
import 'dart:convert';

import 'package:spark_rest/src/server/chain/endpoint.dart';
import 'package:spark_rest/src/server/router/method.dart';
import 'package:spark_rest/src/server/router/uri.dart';
import 'package:spark_rest/src/server/actuator/endpoint.dart';
import 'package:spark_rest/src/server/actuator/middleware.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/foundation/context.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';

abstract class Application implements Initializable, Handlable<Request, Response> {

  factory Application({
    required List<Middleware<Request>> requestMiddlewares,
    required List<Endpoint> endpoints,
    required List<Middleware<Response>> responseMiddlewares,
  }) => _ApplicationV1(
    requestMiddlewares: requestMiddlewares,
    endpoints: endpoints,
    responseMiddlewares: responseMiddlewares,
  );

}

class _ApplicationV1 implements Application {

  _ApplicationV1({
    required this.requestMiddlewares,
    required this.endpoints,
    required this.responseMiddlewares,
  });

  final List<Middleware<Request>> requestMiddlewares;
  final List<Endpoint> endpoints;
  final List<Middleware<Response>> responseMiddlewares;

  late UriRouter uriRouter;

  @override
  Future<void> onInit(Context context) async {
    // get router instance
    uriRouter = context.findObjectOfType<UriRouter>();
    // create the router chain
    for (var endpoint in endpoints) {
      uriRouter
        .putIfAbsent(endpoint.uri, () => MethodRouter())
        .putIfAbsent(endpoint.method, () => EndpointChain(
          requestMiddlewares: [],
          endpoint: endpoint,
          responseMiddlewares: [],
        ));
    }
    for (var requestMiddleware in requestMiddlewares) {
      uriRouter.forEach(
        (uri, methodRouter) => methodRouter.forEach(
          (method, endpointChain) =>
            requestMiddleware.attachTo(uri, method) ?
              requestMiddleware.attachFunction(endpointChain.requestMiddlewares) :
              null
        )
      );
    }
    for (var responseMiddleware in responseMiddlewares) {
      uriRouter.forEach(
        (uri, methodRouter) => methodRouter.forEach(
          (method, endpointChain) =>
            responseMiddleware.attachTo(uri, method) ?
              responseMiddleware.attachFunction(endpointChain.responseMiddlewares) :
              null
        )
      );
    }
    // register elements in the context
    requestMiddlewares.forEach((element) => context.register(element));
    endpoints.forEach((element) => context.register(element));
    responseMiddlewares.forEach((element) => context.register(element));
    // init them
    for (var requestMiddleware in requestMiddlewares) {
      await requestMiddleware.onInit(context);
    }
    for (var responseMiddleware in responseMiddlewares) {
      await responseMiddleware.onInit(context);
    }
    for (var endpoint in endpoints) {
      await endpoint.onInit(context);
    }
  }

  @override
  Future<Response> onHandle(Request request) async {
    try {
      return uriRouter.onHandle(request);
    } on Response catch (response) {
      return response;
    } catch (error) {
      return Response(
        request: request,
        statusCode: 500,
        headers: {},
        contentType: ContentType.json,
        body: json.encode({'error': '$error'})
      );
    }
  }

}