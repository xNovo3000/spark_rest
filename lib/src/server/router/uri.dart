import 'dart:collection';
import 'dart:io';

import 'package:spark_rest/src/server/chain/uri.dart';
import 'package:spark_rest/src/server/container/context.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';

class UriRouter extends MapBase<String, UriChain>
    implements Handlable<Response, Request> {
  final Map<String, UriChain> _map = HashMap();

  @override
  UriChain? operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, UriChain value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  UriChain? remove(Object? key) => _map.remove(key);

  @override
  Future<Response> onHandle(Request request) async {
    var uriChain = this[request.uri.path];
    if (uriChain == null) {
      return Response(
        request: request,
        statusCode: 404,
        headers: {},
        contentType: ContentType.json,
        body: '{"message":"The uri does not exists"}',
      );
    }
    return uriChain.onHandle(request);
  }

  static UriRouter of(final Context context) =>
      context.findInstanceOfType<UriRouter>();
}
