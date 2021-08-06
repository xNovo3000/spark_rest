import 'package:spark_rest/src/server/endpoint.dart';
import 'package:spark_rest/src/server/middleware.dart';
import 'package:spark_rest/src/server/request.dart';
import 'package:spark_rest/src/server/response.dart';

class Chain {
  const Chain({
    required this.requestMiddlewares,
    required this.endpoint,
    required this.responseMiddlewares,
  });

  final List<Middleware<Request>> requestMiddlewares;
  final Endpoint endpoint;
  final List<Middleware<Response>> responseMiddlewares;

  Future<Response> onHandle(Request request) async {
    try {
      for (var middleware in requestMiddlewares) {
        request = await middleware.onHandle(request);
      }
      var response = await endpoint.onHandle(request);
      for (var middleware in responseMiddlewares) {
        response = await middleware.onHandle(response);
      }
      return response;
    } on Response catch (response) {
      return response;
    } catch (e) {
      return Response.error(
          request: request, statusCode: 500, message: e.toString());
    }
  }
}
