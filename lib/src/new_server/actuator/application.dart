import 'dart:convert';

import 'package:spark_rest/src/new_server/actuator/endpoint.dart';
import 'package:spark_rest/src/new_server/actuator/middleware.dart';
import 'package:spark_rest/src/new_server/chain/endpoint.dart';
import 'package:spark_rest/src/new_server/chain/uri.dart';
import 'package:spark_rest/src/new_server/container/method.dart';
import 'package:spark_rest/src/new_server/container/request.dart';
import 'package:spark_rest/src/new_server/container/response.dart';
import 'package:spark_rest/src/new_server/interface/handlable.dart';
import 'package:spark_rest/src/new_server/interface/initializable.dart';
import 'package:spark_rest/src/new_server/router/method.dart';
import 'package:spark_rest/src/new_server/router/uri.dart';

abstract class Application
    implements Initializable, Handlable<Response, Request> {
  final UriRouter _router = UriRouter();

  void registerEndpoint(
      final String uri, final Method method, final Endpoint endpoint) {
    _router
        .putIfAbsent(
            uri, () => UriChain(middlewares: [], methodRouter: MethodRouter()))
        .methodRouter
        .putIfAbsent(
            method,
            () => EndpointChain(
                requestMiddlewares: [],
                endpoint: endpoint,
                responseMiddlewares: []));
  }

  void registerMiddleware<T>(
      final String uri, final Middleware<T> middleware) {}
  void registerPlugin() {}

  @override
  Future<Response> onHandle(Request request) async {
    try {
      return _router.onHandle(request);
    } on Response catch (response) {
      return response;
    } catch (e) {
      return Response(
          request: request,
          statusCode: 500,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'error': '$e'}));
    }
  }
}
