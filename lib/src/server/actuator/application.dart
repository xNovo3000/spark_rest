import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:spark_rest/src/addon/plugin.dart';
import 'package:spark_rest/src/server/actuator/endpoint.dart';
import 'package:spark_rest/src/server/actuator/middleware.dart';
import 'package:spark_rest/src/server/chain/endpoint.dart';
import 'package:spark_rest/src/server/chain/uri.dart';
import 'package:spark_rest/src/server/container/context.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/container/middleware_attach_type.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';
import 'package:spark_rest/src/server/router/method.dart';
import 'package:spark_rest/src/server/router/uri.dart';

/// The starting point of a SparkREST application
abstract class Application
    implements Initializable, Handlable<Response, Request> {
  final UriRouter _router = UriRouter();
  final _ServerOptimizedContext _context = _ServerOptimizedContext();

  /// Used to register and endpoint
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
    _context.register(endpoint);
  }

  /// Used to register a [Middleware] in a single location
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
    _context.register(middleware);
  }

  /// Used to register a [Middleware] in multiple location based on [Middleware.attachTo]
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
    _context.register(middleware);
  }

  /// Used to register a Plugin
  void registerPlugin(final Plugin plugin) =>
      print('Plugins are not available in this version');

  /// Used to register an enviromental variable
  void registerEnviromentalVariable(Object variable) =>
      _context.register(variable);

  /// Registers everything. Do not call and/or override this method. Use [onInit] instead
  Future<void> onInitServer() async {
    // register the router in the context (must be the first)
    _context.register(_router);
    // register all user endpoints and middlewares
    await onInit(_context);
    // handle all already loaded middlewares
    Set<Middleware<Request>> alreadyLoadedRequestMiddlewares = HashSet();
    Set<Middleware<Response>> alreadyLoadedResponseMiddlewares = HashSet();
    // load everything
    for (var a1 in _router.entries) {
      for (var middleware in a1.value.middlewares) {
        if (!alreadyLoadedRequestMiddlewares.contains(middleware)) {
          await middleware.onInit(_context);
          alreadyLoadedRequestMiddlewares.add(middleware);
        }
      }
      for (var a2 in a1.value.methodRouter.entries) {
        for (var middleware in a2.value.requestMiddlewares) {
          if (!alreadyLoadedRequestMiddlewares.contains(middleware)) {
            await middleware.onInit(_context);
            alreadyLoadedRequestMiddlewares.add(middleware);
          }
        }
        for (var middleware in a2.value.responseMiddlewares) {
          if (!alreadyLoadedResponseMiddlewares.contains(middleware)) {
            await middleware.onInit(_context);
            alreadyLoadedResponseMiddlewares.add(middleware);
          }
        }
        await a2.value.endpoint.onInit(_context);
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

class _ServerOptimizedContext extends Context {
  final List _objects = [];

  void register(Object object) =>
      _objects.contains(object) ? null : _objects.add(object);

  @override
  T findInstanceOfType<T>() => _objects.whereType<T>().first;

  @override
  Iterable<T> findInstancesOfType<T>() => _objects.whereType<T>();
}
