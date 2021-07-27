import 'package:spark_http/src/server/request.dart';
import 'package:spark_http/src/server/response.dart';

abstract class Middleware<T> {

	Middleware() : assert(T == Request || T == Response);

	Future<void> onInit(String uri, String method) async => null;

	Future<T> onHandle(final T data);

	Middleware<T> clone() => throw UnsupportedError('This middleware is a singleton');

	bool get singleton => true;

	bool Function(String method, String uri)? get appendOverride => null;

	bool get appendAtBegin => false;

}