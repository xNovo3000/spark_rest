import 'package:spark_rest/src/new_server/actuator/endpoint.dart';
import 'package:spark_rest/src/new_server/actuator/middleware.dart';
import 'package:spark_rest/src/new_server/container/request.dart';
import 'package:spark_rest/src/new_server/container/response.dart';
import 'package:spark_rest/src/new_server/interface/handlable.dart';

class EndpointChain implements Handlable<Response, Request> {
  const EndpointChain({
    required this.requestMiddlewares,
    required this.endpoint,
    required this.responseMiddlewares,
  });

  final List<Middleware<Request>> requestMiddlewares;
  final Endpoint endpoint;
  final List<Middleware<Response>> responseMiddlewares;

  @override
  Future<Response> onHandle(Request param) async {
    for (var requestMiddleware in requestMiddlewares) {
      param = await requestMiddleware.onHandle(param);
    }
    var response = await endpoint.onHandle(param);
    for (var responseMiddleware in responseMiddlewares) {
      response = await responseMiddleware.onHandle(response);
    }
    return response;
  }
}
