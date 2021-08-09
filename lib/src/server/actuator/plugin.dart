import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/actuator/middleware.dart';

abstract class Plugin {

  Iterable<Middleware<Request>> get requestMiddlewares => const [];
  Iterable<Middleware<Response>> get responseMiddlewares => const [];

}