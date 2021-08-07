import 'dart:collection';

import 'package:spark_rest/src/new_server/chain/uri.dart';
import 'package:spark_rest/src/new_server/container/request.dart';
import 'package:spark_rest/src/new_server/container/response.dart';
import 'package:spark_rest/src/new_server/interface/handlable.dart';

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
  Future<Response> onHandle(Request param) async {
    var uriChain = this[param.uri.path];
    if (uriChain == null) {
      // TODO: return error response
      throw Error();
    }
    return uriChain.onHandle(param);
  }
}
