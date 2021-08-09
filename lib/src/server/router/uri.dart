import 'dart:io';
import 'dart:collection';

import 'package:spark_rest/spark_rest.dart';
import 'package:spark_rest/src/server/router/method.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';

/// Convenience class that can dispatch Uris
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
    var methodRouter = this[request.uri.path];
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

  /// Convenience method used to get the [UriRouter] from a [Context]
  static UriRouter of(Context context) => context.findObjectOfType<UriRouter>();
}
