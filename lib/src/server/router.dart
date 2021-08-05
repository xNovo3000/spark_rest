import 'dart:collection';

import 'package:spark_rest/src/server/chain.dart';
import 'package:spark_rest/src/server/endpoint.dart';
import 'package:spark_rest/src/server/middleware.dart';
import 'package:spark_rest/src/server/request.dart';
import 'package:spark_rest/src/server/response.dart';

class Router {

	final Map<String, Map<String, Chain>> _tree = HashMap();

	void appendRoute({
		required List<Middleware<Request>> requestMiddlewares,
		required List<Middleware<Response>> responseMiddlewares,
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
				// generate middleware
				var newMiddleware = middleware.singleton ? middleware : middleware.clone();
				// append
				if (T == Request) {
					if (middleware.appendAtBegin) {
						chain.requestMiddlewares.insert(0, newMiddleware as Middleware<Request>);
					} else {
						chain.requestMiddlewares.add(newMiddleware as Middleware<Request>);
					}
				} else { // T == Response
					if (middleware.appendAtBegin) {
						chain.responseMiddlewares.insert(0, newMiddleware as Middleware<Response>);
					} else {
						chain.responseMiddlewares.add(newMiddleware as Middleware<Response>);
					}
				}
			}
		}));
	}

	void loadObjects() {
		// contains all middlwares already loaded
		var loadedRequestMiddlewares = <Middleware<Request>>[];
		var loadedResponseMiddlewares = <Middleware<Response>>[];
		// loads all
		_tree.forEach((uri, map) => map.forEach((method, chain) {
			chain.requestMiddlewares.forEach((requestMiddleware) {
				if (!loadedRequestMiddlewares.contains(requestMiddleware)) {
					requestMiddleware.onInit(uri, method);
					loadedRequestMiddlewares.add(requestMiddleware);
				}
			});
			chain.endpoint.onInit(uri, method);
			chain.responseMiddlewares.forEach((responseMiddleware) {
				if (!loadedResponseMiddlewares.contains(responseMiddleware)) {
					responseMiddleware.onInit(uri, method);
					loadedResponseMiddlewares.add(responseMiddleware);
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