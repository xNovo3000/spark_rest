import 'package:spark_rest/src/abstract_server/actuator/endpoint.dart';
import 'package:spark_rest/src/abstract_server/actuator/middleware.dart';
import 'package:spark_rest/src/abstract_server/container/request.dart';
import 'package:spark_rest/src/abstract_server/container/response.dart';

abstract class Context {

  void register<T>(T element);

  T findObjectOfType<T>();

  Iterable<T> findObjectsOfType<T>();

  Endpoint findAttachedEndpoint<T>(Middleware<T> middleware);

  T findAttachedRequestMiddlewareOfType<T extends Middleware<Request>>(Endpoint endpoint);

  T findAttachedResponseMiddlewareOfType<T extends Middleware<Request>>(Endpoint endpoint);

  Iterable<Middleware<Request>> findAttachedRequestMiddlewares(Endpoint endpoint);

  Iterable<Middleware<Response>> findAttachedResponseMiddlewares(Endpoint endpoint);

}