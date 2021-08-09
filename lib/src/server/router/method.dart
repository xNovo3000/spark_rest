import 'dart:io';
import 'dart:collection';

import 'package:spark_rest/spark_rest.dart';
import 'package:spark_rest/src/server/chain/endpoint.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/foundation/context.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';

class MethodRouter extends MapBase<Method, EndpointChain>
    implements Handlable<Request, Response> {

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
  Future<Response> onHandle(Request request) async {
    var endpointChain = this[request.method];
    if (endpointChain == null) {
      return Response(
        request: request,
        statusCode: 404,
        headers: {},
        contentType: ContentType.json,
        body: '{"message":"The method does not exists"}',
      );
    }
    return endpointChain.onHandle(request);
  }

  static MethodRouter of(Context context, String uri) =>
      UriRouter.of(context)[uri]!;

}