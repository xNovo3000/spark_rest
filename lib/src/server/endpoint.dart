import 'package:spark_rest/src/server/request.dart';
import 'package:spark_rest/src/server/response.dart';

/// A single endpoint in the server
abstract class Endpoint {

	/// Constructor
	const Endpoint({
		required this.method,
		required this.uri,
		this.requestMiddlewares = const [],
		this.responseMiddlewares = const [],
	});

	/// The accepted HTTP method
	final String method;

	/// The accepted [Uri] substring
	final String uri;

	/// The required request middlewares
	final List<String> requestMiddlewares;

	/// The required response middlewares
	final List<String> responseMiddlewares;

	/// Executed one time when the [Endpoint] is initialized
	/// 
	/// Do not call this function on purpose, it is called for you from Spark.
	Future<void> onInit(String uri, String method) async => null;

	/// Executed every time a [Request] should pass in this [Endpoint]
	/// 
	/// Do not call this function on purpose
	Future<Response> onHandle(final Request request);
	
}