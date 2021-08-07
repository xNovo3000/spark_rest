import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:spark_rest/src/server/actuator/endpoint.dart';
import 'package:spark_rest/src/server/actuator/middleware.dart';
import 'package:spark_rest/src/server/chain/endpoint.dart';
import 'package:spark_rest/src/server/chain/uri.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/container/middleware_attach_type.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';
import 'package:spark_rest/src/server/router/method.dart';
import 'package:spark_rest/src/server/router/uri.dart';

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

  void registerSingleMiddleware<T>(final String? uri, final Method? method,
      final MiddlewareAttachType attachType, final Middleware<T> middleware) {
    switch (attachType) {
      case MiddlewareAttachType.whenUriHasBeenExtracted:
        assert(T == Request, 'Must be a reuqest middleware');
        assert(uri != null, 'Uri must not be null');
        _router[uri]!.middlewares.add(middleware as Middleware<Request>);
        break;
      case MiddlewareAttachType.whenMethodHasBeenExtracted:
        assert(T == Request, 'Must be a reuqest middleware');
        assert(uri != null, 'Uri must not be null');
        assert(method != null, 'Method must not be null');
        _router[uri]!
            .methodRouter[method]!
            .requestMiddlewares
            .add(middleware as Middleware<Request>);
        break;
      case MiddlewareAttachType.afterEndpointExecution:
        assert(T == Response, 'Must be a response middleware');
        assert(uri != null, 'Uri must not be null');
        assert(method != null, 'Method must not be null');
        _router[uri]!
            .methodRouter[method]!
            .responseMiddlewares
            .add(middleware as Middleware<Response>);
        break;
    }
  }

  void registerWidespreadMiddleware<T>(
      final MiddlewareAttachType attachType, final Middleware<T> middleware) {
    switch (attachType) {
      case MiddlewareAttachType.whenUriHasBeenExtracted:
        assert(T == Request, 'Must be a reuqest middleware');
        for (var mapBase in _router.entries) {
          if (middleware.attachTo(mapBase.key, null)) {
            var instance = middleware.clone ?? middleware;
            mapBase.value.middlewares.add(instance as Middleware<Request>);
          }
        }
        break;
      case MiddlewareAttachType.whenMethodHasBeenExtracted:
        assert(T == Request, 'Must be a reuqest middleware');
        for (var mapBase in _router.entries) {
          for (var methodMap in mapBase.value.methodRouter.entries) {
            if (middleware.attachTo(mapBase.key, methodMap.key)) {
              var instance = middleware.clone ?? middleware;
              methodMap.value.requestMiddlewares
                  .add(instance as Middleware<Request>);
            }
          }
        }
        break;
      case MiddlewareAttachType.afterEndpointExecution:
        assert(T == Response, 'Must be a response middleware');
        for (var mapBase in _router.entries) {
          for (var methodMap in mapBase.value.methodRouter.entries) {
            if (middleware.attachTo(mapBase.key, methodMap.key)) {
              var instance = middleware.clone ?? middleware;
              methodMap.value.responseMiddlewares
                  .add(instance as Middleware<Response>);
            }
          }
        }
        break;
    }
  }

  void registerPlugin() {}

  @override
  Future<void> onInit(final Application application) async {
    Set<Middleware<Request>> alreadyLoadedRequestMiddlewares = HashSet();
    Set<Middleware<Response>> alreadyLoadedResponseMiddlewares = HashSet();
    for (var a1 in _router.entries) {
      for (var middleware in a1.value.middlewares) {
        if (!alreadyLoadedRequestMiddlewares.contains(middleware)) {
          await middleware.onInit(application);
          alreadyLoadedRequestMiddlewares.add(middleware);
        }
      }
      for (var a2 in a1.value.methodRouter.entries) {
        for (var middleware in a2.value.requestMiddlewares) {
          if (!alreadyLoadedRequestMiddlewares.contains(middleware)) {
            await middleware.onInit(application);
            alreadyLoadedRequestMiddlewares.add(middleware);
          }
        }
        for (var middleware in a2.value.responseMiddlewares) {
          if (!alreadyLoadedResponseMiddlewares.contains(middleware)) {
            await middleware.onInit(application);
            alreadyLoadedResponseMiddlewares.add(middleware);
          }
        }
        await a2.value.endpoint.onInit(application);
      }
    }
  }

  @override
  Future<Response> onHandle(Request request) async {
    try {
      return _router.onHandle(request);
    } on Response catch (response) {
      return response;
    } catch (error) {
      return Response(
          request: request,
          statusCode: 500,
          headers: {},
          contentType: ContentType.json,
          body: json.encode({'error': '$error'}));
    }
  }
}
