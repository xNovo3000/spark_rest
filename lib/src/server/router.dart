import 'dart:collection';

import 'package:spark_http/src/server/chain.dart';
import 'package:spark_http/src/server/endpoint.dart';
import 'package:spark_http/src/server/middleware.dart';
import 'package:spark_http/src/server/request.dart';
import 'package:spark_http/src/server/response.dart';

class Router {

	final Map<String, Map<String, Chain>> _tree = HashMap();

	void appendRoute({
		List<Middleware<Request>> requestMiddlewares = const [],
		List<Middleware<Response>> responseMiddlewares = const [],
		required Endpoint endpoint,
	}) => _tree.putIfAbsent(endpoint.uri, () => HashMap()).putIfAbsent(endpoint.method, () => Chain(
		requestMiddlewares: requestMiddlewares,
		responseMiddlewares: responseMiddlewares,
		endpoint: endpoint
	));

	void appendMiddleware<T>(Middleware<T> middleware, bool atBegin) {
		_tree.forEach((uri, map) => map.forEach((method, chain) {
			var result = middleware.appendOverride!(method, uri);
			if (result) {
				if (T == Request) {
					if (middleware.appendAtBegin) {
						chain.requestMiddlewares.insert(0, middleware as Middleware<Request>);
					} else {
						chain.requestMiddlewares.add(middleware as Middleware<Request>);
					}
				} else { // T == Response
					if (middleware.appendAtBegin) {
						chain.responseMiddlewares.insert(0, middleware as Middleware<Response>);
					} else {
						chain.responseMiddlewares.add(middleware as Middleware<Response>);
					}
				}
			}
		}));
	}

	Future<void> loadObjects() async {
		// contains all middlwares already loaded
		Set<Middleware<Request>> loadedRequestMiddlewares = HashSet();
		Set<Middleware<Response>> loadedResponseMiddlewares = HashSet();
		// loads all
		_tree.forEach((uri, map) => map.forEach((method, chain) async {
			chain.requestMiddlewares.forEach((requestMiddleware) async {
				if (!loadedRequestMiddlewares.contains(requestMiddleware)) {
					await requestMiddleware.onInit(uri, method);
				}
			});
			await chain.endpoint.onInit(uri, method);
			chain.responseMiddlewares.forEach((responseMiddleware) async {
				if (!loadedResponseMiddlewares.contains(responseMiddleware)) {
					await responseMiddleware.onInit(uri, method);
				}
			});
		}));
	}

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