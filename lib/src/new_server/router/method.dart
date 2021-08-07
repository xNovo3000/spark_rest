import 'dart:collection';

import 'package:spark_rest/src/new_server/chain/endpoint.dart';
import 'package:spark_rest/src/new_server/container/method.dart';
import 'package:spark_rest/src/new_server/container/request.dart';
import 'package:spark_rest/src/new_server/container/response.dart';
import 'package:spark_rest/src/new_server/interface/handlable.dart';

class MethodRouter extends MapBase<Method, EndpointChain>
    implements Handlable<Response, Request> {
  final Map<Method, EndpointChain> _map = HashMap();

  @override
  EndpointChain? operator [](Object? key) => _map[key];

  @override
  void operator []=(Method key, EndpointChain value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<Method> get keys => _map.keys;

  @override
  EndpointChain? remove(Object? key) => _map.remove(key);

  @override
  Future<Response> onHandle(Request param) async {
    var endpointChain = this[param.method];
    if (endpointChain == null) {
      // TODO: return error response
      throw Error();
    }
    return endpointChain.onHandle(param);
  }
}
