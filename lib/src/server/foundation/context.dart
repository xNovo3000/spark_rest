import 'package:spark_rest/src/server/actuator/endpoint.dart';
import 'package:spark_rest/src/server/actuator/middleware.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/router/uri.dart';

/// Contains all the environment variables of the application
abstract class Context {
  /// Factory constructor
  factory Context() => _ContextV1();

  /// Used to register an element in the context
  void register<T>(T element);

  /// Used to find an object of type [T]
  ///
  /// If there are more objects of type [T], a [StateError] is thrown
  T findObjectOfType<T>();

  /// Used to find all objects of type [T]
  Iterable<T> findObjectsOfType<T>();

  /// Given a [Middleware] instance, finds the attached [Endpoint]
  Endpoint findAttachedEndpoint<T>(Middleware<T> middleware);

  /// Given a [Endpoint] instance, finds the
  /// attached request [Middleware] of subtype [T]
  T findAttachedRequestMiddlewareOfType<T extends Middleware<Request>>(
      Endpoint endpoint);

  /// Given a [Endpoint] instance, finds the
  /// attached response [Middleware] of subtype [T]
  T findAttachedResponseMiddlewareOfType<T extends Middleware<Response>>(
      Endpoint endpoint);

  /// Given a [Endpoint] instance, finds all the attached request middlewares
  Iterable<Middleware<Request>> findAttachedRequestMiddlewares(
      Endpoint endpoint);

  /// Given a [Endpoint] instance, finds all the attached response middlewares
  Iterable<Middleware<Response>> findAttachedResponseMiddlewares(
      Endpoint endpoint);
}

class _ContextV1 implements Context {
  final List objects = [];

  @override
  void register<T>(T element) => objects.add(element);

  @override
  T findObjectOfType<T>() => objects.whereType<T>().single;

  @override
  Iterable<T> findObjectsOfType<T>() => objects.whereType<T>();

  @override
  Endpoint findAttachedEndpoint<T>(Middleware<T> middleware) {
    final uriRouter = UriRouter.of(this);
    for (var a1 in uriRouter.entries) {
      for (var a2 in a1.value.entries) {
        if (T == Request) {
          for (var requestMiddleware in a2.value.requestMiddlewares) {
            if (requestMiddleware == middleware) {
              return a2.value.endpoint;
            }
          }
        } else {
          // T == Response
          for (var responseMiddleware in a2.value.responseMiddlewares) {
            if (responseMiddleware == middleware) {
              return a2.value.endpoint;
            }
          }
        }
      }
    }
    throw StateError('Middleware of type $middleware not found');
  }

  @override
  T findAttachedRequestMiddlewareOfType<T extends Middleware<Request>>(
      Endpoint endpoint) {
    final requestMiddlewares = findAttachedRequestMiddlewares(endpoint);
    return requestMiddlewares.singleWhere((element) => element is T) as T;
  }

  @override
  T findAttachedResponseMiddlewareOfType<T extends Middleware<Response>>(
      Endpoint endpoint) {
    final responseMiddlewares = findAttachedResponseMiddlewares(endpoint);
    return responseMiddlewares.singleWhere((element) => element is T) as T;
  }

  @override
  Iterable<Middleware<Request>> findAttachedRequestMiddlewares(
      Endpoint endpoint) {
    final uriRouter = UriRouter.of(this);
    for (var a1 in uriRouter.entries) {
      for (var a2 in a1.value.entries) {
        if (a2.value.endpoint == endpoint) {
          return a2.value.requestMiddlewares;
        }
      }
    }
    throw StateError('Endpoint of type $endpoint not found');
  }

  @override
  Iterable<Middleware<Response>> findAttachedResponseMiddlewares(
      Endpoint endpoint) {
    final uriRouter = UriRouter.of(this);
    for (var a1 in uriRouter.entries) {
      for (var a2 in a1.value.entries) {
        if (a2.value.endpoint == endpoint) {
          return a2.value.responseMiddlewares;
        }
      }
    }
    throw StateError('Endpoint of type $endpoint not found');
  }
}
