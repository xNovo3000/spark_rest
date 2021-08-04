import 'package:spark_rest/src/server/request.dart';
import 'package:spark_rest/src/server/response.dart';

abstract class Endpoint {

	const Endpoint({
		required this.method,
		required this.uri,
		this.requestMiddlewares = const [],
		this.responseMiddlewares = const [],
	});

	final String method;
	final String uri;
	final List<String> requestMiddlewares;
	final List<String> responseMiddlewares;

	Future<void> onInit(String uri, String method) async => null;

	Future<Response> onHandle(final Request request);
	
}