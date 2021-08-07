import 'package:spark_rest/src/server/actuator/middleware.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/router/method.dart';

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
