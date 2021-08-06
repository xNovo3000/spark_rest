import 'dart:collection';

import 'package:spark_rest/src/server/chain.dart';
import 'package:spark_rest/src/server/endpoint.dart';
import 'package:spark_rest/src/server/middleware.dart';
import 'package:spark_rest/src/server/request.dart';
import 'package:spark_rest/src/server/response.dart';

class Router {
  final Map<String, Map<String, Chain>> _tree = HashMap();

  void appendRoute({
    required List<Middleware<Request>> requestMiddlewares,
    required List<Middleware<Response>> responseMiddlewares,
    required Endpoint endpoint,
  }) =>
      _tree.putIfAbsent(endpoint.uri, () => HashMap()).putIfAbsent(
          endpoint.method,
          () => Chain(
              requestMiddlewares: requestMiddlewares,
              responseMiddlewares: responseMiddlewares,
              endpoint: endpoint));

  void appendMiddleware<T>(Middleware<T> middleware, bool atBegin) {
    _tree.forEach((uri, map) => map.forEach((method, chain) {
          var result = middleware.appendOverride!(method, uri);
          if (result) {
            // generate middleware
            var newMiddleware =
                middleware.singleton ? middleware : middleware.clone();
            // append
            if (T == Request) {
              if (middleware.appendAtBegin) {
                chain.requestMiddlewares
                    .insert(0, newMiddleware as Middleware<Request>);
              } else {
                chain.requestMiddlewares
                    .add(newMiddleware as Middleware<Request>);
              }
            } else {
              // T == Response
              if (middleware.appendAtBegin) {
                chain.responseMiddlewares
                    .insert(0, newMiddleware as Middleware<Response>);
              } else {
                chain.responseMiddlewares
                    .add(newMiddleware as Middleware<Response>);
              }
            }
          }
        }));
  }

  Future<void> loadObjects() async {
    // contains all middlwares already loaded
    var loadedRequestMiddlewares = <Middleware<Request>>[];
    var loadedResponseMiddlewares = <Middleware<Response>>[];
    // loads all
    for (var x in _tree.entries) {
      for (var y in x.value.entries) {
        // get method and chain
        var chain = y.value;
        // for each request middleware
        for (var requestMiddleware in chain.requestMiddlewares) {
          if (!loadedRequestMiddlewares.contains(requestMiddleware)) {
            await requestMiddleware.onInit(this);
            loadedRequestMiddlewares.add(requestMiddleware);
          }
        }
        // init endpoints
        await chain.endpoint.onInit(this);
        // for each response middleware
        for (var responseMiddleware in chain.responseMiddlewares) {
          if (!loadedResponseMiddlewares.contains(responseMiddleware)) {
            await responseMiddleware.onInit(this);
            loadedResponseMiddlewares.add(responseMiddleware);
          }
        }
      }
    }
  }

  Future<Response> onHandle(final Request request) async {
    var methods = _tree[request.uri.path];
    if (methods == null) return Response.error(request: request);
    var chain = methods[request.method];
    if (chain == null) return Response.error(request: request);
    return chain.onHandle(request);
  }

  Map<String, List<String>> get tree {
    var result = <String, List<String>>{};
    _tree.forEach((uri, map) {
      var list = <String>[];
      map.forEach((method, chain) => list.add(method));
      result[uri] = list;
    });
    return result;
  }

}
