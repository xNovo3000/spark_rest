import 'dart:io';
import 'dart:convert';

import 'package:spark_rest/src/server/chain/endpoint.dart';
import 'package:spark_rest/src/server/actuator/plugin.dart';
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
    List<Middleware<Request>> requestMiddlewares = const [],
    List<Endpoint> endpoints = const [],
    List<Middleware<Response>> responseMiddlewares = const [],
    List<Plugin> plugins = const [],
  }) => _ApplicationV1(
    requestMiddlewares: requestMiddlewares,
    endpoints: endpoints,
    responseMiddlewares: responseMiddlewares,
    plugins: plugins,
  );

  Iterable<Middleware<Request>> get requestMiddlewares;
  Iterable<Endpoint> get endpoints;
  Iterable<Middleware<Response>> get responseMiddlewares;
  Iterable<Plugin> get plugins;

}

class _ApplicationV1 implements Application {

  _ApplicationV1({
    required this.requestMiddlewares,
    required this.endpoints,
    required this.responseMiddlewares,
    required this.plugins,
  });

  @override
  final List<Middleware<Request>> requestMiddlewares;
  @override
  final List<Endpoint> endpoints;
  @override
  final List<Middleware<Response>> responseMiddlewares;
  @override
  final List<Plugin> plugins;

  late UriRouter uriRouter;

  @override
  Future<void> onInit(Context context) async {
    // get router instance
    uriRouter = UriRouter.of(context);
    // append plugins
    for (var plugin in plugins) {
      requestMiddlewares.addAll(plugin.requestMiddlewares);
      responseMiddlewares.addAll(plugin.responseMiddlewares);
    }
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