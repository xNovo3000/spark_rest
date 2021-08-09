import 'dart:io';
import 'dart:collection';

import 'package:spark_rest/src/abstract_server/router/method.dart';
import 'package:spark_rest/src/abstract_server/container/request.dart';
import 'package:spark_rest/src/abstract_server/container/response.dart';
import 'package:spark_rest/src/abstract_server/interface/handlable.dart';

class UriRouter extends MapBase<String, MethodRouter>
    implements Handlable<Request, Response> {

  final Map<String, MethodRouter> _map = HashMap();

  @override
  MethodRouter? operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, MethodRouter value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  MethodRouter? remove(Object? key) => _map.remove(key);

  @override
  Future<Response> onHandle(Request request) async {
    var methodRouter = this[request.method];
    if (methodRouter == null) {
      return Response(
        request: request,
        statusCode: 404,
        headers: {},
        contentType: ContentType.json,
        body: '{"message":"The uri does not exists"}',
      );
    }
    return methodRouter.onHandle(request);
  }

}