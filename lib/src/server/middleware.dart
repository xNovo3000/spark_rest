import 'package:spark_rest/src/server/request.dart';
import 'package:spark_rest/src/server/response.dart';
import 'package:spark_rest/src/server/router.dart';

/// The base class for request and response middlewares
///
/// The type of the [Middleware] must be wither [Request] or [Response].
abstract class Middleware<T> {
  /// Constructor
  ///
  /// Use the constructor ONLY if you need to initialize a variable and it is a Singleton.
  /// Otherwise, use the [onInit] method.
  Middleware() : assert(T == Request || T == Response);

  /// Executed one time when the [Middleware] is initialized
  ///
  /// Do not call this function on purpose, it is called for you from Spark.
  Future<void> onInit(final Router router) async => null;

  /// Executed every time a [Request] or a [Response] should pass in this [Middleware]
  ///
  /// If you are in a request middleware and you don't want to pass the request to the endpoint,
  /// then throw a [Response] error.
  ///
  /// ```dart
  /// throw Response(...);
  /// ```
  ///
  /// Do not call this function on purpose.
  Future<T> onHandle(final T data);

  /// Executed when your middleware is not a singleton
  ///
  /// You must create your own clone function.
  Middleware<T> clone() =>
      throw UnsupportedError('This middleware is a singleton');

  /// This [Middleware] is a singleton: the same instance goes to every endpoint
  bool get singleton => true;

  /// Used to verify if a [Middleware] must be appended to different endpoints
  bool Function(String method, String uri)? get appendOverride => null;

  /// If [appendOverride] is not null, is used to verify if this [Middleware] must be appended at the begin
  bool get appendAtBegin => false;
}
