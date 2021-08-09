import 'package:spark_rest/src/abstract_server/actuator/endpoint.dart';
import 'package:spark_rest/src/abstract_server/actuator/middleware.dart';
import 'package:spark_rest/src/abstract_server/container/request.dart';
import 'package:spark_rest/src/abstract_server/container/response.dart';
import 'package:spark_rest/src/abstract_server/router/uri.dart';

abstract class Context {

  factory Context() => _ContextV1();

  void register<T>(T element);

  T findObjectOfType<T>();

  Iterable<T> findObjectsOfType<T>();

  Endpoint findAttachedEndpoint<T>(Middleware<T> middleware);

  T findAttachedRequestMiddlewareOfType<T extends Middleware<Request>>(Endpoint endpoint);

  T findAttachedResponseMiddlewareOfType<T extends Middleware<Response>>(Endpoint endpoint);

  Iterable<Middleware<Request>> findAttachedRequestMiddlewares(Endpoint endpoint);

  Iterable<Middleware<Response>> findAttachedResponseMiddlewares(Endpoint endpoint);

}

class _ContextV1 implements Context {

  final List objects = [];

  @override
  void register<T>(T element) => objects.add(element);

  @override
  T findObjectOfType<T>() => objects.whereType<T>().first;

  @override
  Iterable<T> findObjectsOfType<T>() => objects.whereType<T>();

  @override
  Endpoint findAttachedEndpoint<T>(Middleware<T> middleware) {
    final uriRouter = findObjectOfType<UriRouter>();
    for (var a1 in uriRouter.entries) {
      for (var a2 in a1.value.entries) {
        if (T == Request) {
          for (var requestMiddleware in a2.value.requestMiddlewares) {
            if (requestMiddleware == middleware) {
              return a2.value.endpoint;
            }
          }
        } else { // T == Response
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
  T findAttachedRequestMiddlewareOfType<T extends Middleware<Request>>(Endpoint endpoint) {
    final requestMiddlewares = findAttachedRequestMiddlewares(endpoint);
    return requestMiddlewares.singleWhere((element) => element is T) as T;
  }

  @override
  T findAttachedResponseMiddlewareOfType<T extends Middleware<Response>>(Endpoint endpoint) {
    final responseMiddlewares = findAttachedResponseMiddlewares(endpoint);
    return responseMiddlewares.singleWhere((element) => element is T) as T;
  }

  @override
  Iterable<Middleware<Request>> findAttachedRequestMiddlewares(Endpoint endpoint) {
    final uriRouter = findObjectOfType<UriRouter>();
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
  Iterable<Middleware<Response>> findAttachedResponseMiddlewares(Endpoint endpoint) {
    final uriRouter = findObjectOfType<UriRouter>();
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