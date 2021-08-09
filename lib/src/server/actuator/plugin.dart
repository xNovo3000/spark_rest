import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/actuator/middleware.dart';

/// Used to inject functionality to a Spark application
abstract class Plugin {
  /// The request middlewares to add to the application
  Iterable<Middleware<Request>> get requestMiddlewares => const [];

  /// The response middlewares to add to the application
  Iterable<Middleware<Response>> get responseMiddlewares => const [];
}
