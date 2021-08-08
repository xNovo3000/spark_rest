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
  /// Constructor
  ///
  /// If you want you can implement custom [UriRouter] and [Context]
  Application({
    UriRouter? uriRouter,
    Context? context,
  })  : _router = uriRouter ?? UriRouter(),
        _context = context ?? _ServerOptimizedContext();

  final UriRouter _router;
  final Context _context;

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
  void registerPlugin(final Plugin plugin) => _context.register(plugin);

  /// Used to register an enviromental variable
  void registerEnviromentalVariable(Object variable) =>
      _context.register(variable);

  @override
  Future<void> onInit(Context context) async {
    // register the router in the context (must be the first)
    _context.register(_router);
    // init all Initializable objects
    var initializableObjects = _context.findInstancesOfType<Initializable>();
    for (var initializableObject in initializableObjects) {
      await initializableObject.onInit(_context);
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

  /// Retrieves the [Context] of this [Application]
  Context get context => _context;
}

class _ServerOptimizedContext extends Context {
  final List _objects = [];

  @override
  void register(Object object) =>
      _objects.contains(object) ? null : _objects.add(object);

  @override
  T findInstanceOfType<T>() => _objects.whereType<T>().first;

  @override
  Iterable<T> findInstancesOfType<T>() => _objects.whereType<T>();
}
