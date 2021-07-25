import 'package:spark_http/src/server/endpoint.dart';

class ChainGenerator {

	const ChainGenerator({
		required this.method,
		required this.uri,
		this.requestMiddlewares = const [],
		this.responseMiddlewares = const [],
		required this.endpoint
	});

	final String method;
	final String uri;
	final List<String> requestMiddlewares;
	final List<String> responseMiddlewares;
	final Endpoint endpoint;

	@override
	bool operator ==(Object other) =>
		other is ChainGenerator ? method == other.method && uri == other.uri : false;
	
	@override
	int get hashCode => method.hashCode + uri.hashCode;

}