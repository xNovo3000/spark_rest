import 'dart:collection';

import 'package:spark_http/src/server/chain.dart';
import 'package:spark_http/src/server/endpoint.dart';
import 'package:spark_http/src/server/middleware.dart';
import 'package:spark_http/src/server/request.dart';
import 'package:spark_http/src/server/response.dart';

class Router {

	final Map<String, Map<String, Chain>> _tree = HashMap();

	void appendRoute({
		required String method,
		required String route,
		List<Middleware<Request>> requestMiddlewares = const [],
		List<Middleware<Response>> responseMiddlewares = const [],
		required Endpoint endpoint,
	}) => _tree.putIfAbsent(route, () => HashMap()).putIfAbsent(method, () => Chain(
		requestMiddlewares: requestMiddlewares,
		responseMiddlewares: responseMiddlewares,
		endpoint: endpoint
	));

	Future<Response> onHandle(final Request request) async {
		var methods = _tree[request.uri.path];
		if (methods == null) return Response.error(request: request);
		var chain = methods[request.method];
		if (chain == null) return Response.error(request: request);
		return chain.onHandle(request);
	}

	List<String> getMethodsForSpecificRoute(final String route) {
		var map = _tree['route'];
		if (map == null) {
		  return [];
		} else {
		  return List.unmodifiable(map.keys);
		}
	}
	
}