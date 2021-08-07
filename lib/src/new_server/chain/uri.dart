import 'package:spark_rest/src/new_server/actuator/middleware.dart';
import 'package:spark_rest/src/new_server/container/request.dart';
import 'package:spark_rest/src/new_server/container/response.dart';
import 'package:spark_rest/src/new_server/interface/handlable.dart';
import 'package:spark_rest/src/new_server/router/method.dart';

class UriChain implements Handlable<Response, Request> {
  const UriChain({
    required this.middlewares,
    required this.methodRouter,
  });

  final List<Middleware<Request>> middlewares;
  final MethodRouter methodRouter;

  @override
  Future<Response> onHandle(Request param) async {
    for (var middleware in middlewares) {
      param = await middleware.onHandle(param);
    }
    return methodRouter.onHandle(param);
  }
}
