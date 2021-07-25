import 'package:spark_http/src/server/request.dart';
import 'package:spark_http/src/server/response.dart';

abstract class Middleware<T> {

	Middleware() : assert(T is Request || T is Response);

	Future<void> onInit();

	Future<T> onHandle(final T data);

	Middleware<T> clone() => throw UnsupportedError('This middleware is a singleton');

	bool get singleton => true;

	bool Function(String method, String uri)? get appendOverride => null;

}