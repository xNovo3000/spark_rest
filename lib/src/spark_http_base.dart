import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spark_http/src/logger/logger.dart';
import 'package:spark_http/src/server/endpoint.dart';
import 'package:spark_http/src/server/middleware.dart';
import 'package:spark_http/src/addon/plugin.dart';
import 'package:spark_http/src/server/request.dart';
import 'package:spark_http/src/server/response.dart';
import 'package:spark_http/src/server/router.dart';

Future boot({
	int port = 8080,
	Map<String, Middleware<Request>> requestMiddlewares = const {},
	Map<String, Middleware<Response>> responseMiddlewares = const {},
	List<Endpoint> endpoints = const [],
	List<Plugin> plugins = const [],
}) {
	// TODO: add plugin handle
	// generate the router
	final router = Router();
	// register endpoints and requested middlewares
	for (var ep in endpoints) {
		router.appendRoute(
			endpoint: ep,
			requestMiddlewares: List.generate(
				ep.requestMiddlewares.length,
				(index) => _handleMiddlewareGet(index, requestMiddlewares, ep),
				growable: true
			),
			responseMiddlewares: List.generate(
				ep.responseMiddlewares.length,
				(index) => _handleMiddlewareGet(index, responseMiddlewares, ep),
				growable: true
			),
		);
	}
	// register widespread request middlewares
	requestMiddlewares.forEach(
		(_, middleware) => middleware.appendOverride != null ?
			router.appendMiddleware(middleware, middleware.appendAtBegin) : null
	);
	// register widespread response middlewares
	responseMiddlewares.forEach(
		(_, middleware) => middleware.appendOverride != null ?
			router.appendMiddleware(middleware, middleware.appendAtBegin) : null
	);
	// init everything
	router.loadObjects();
	// generate the server
	return HttpServer.bind(InternetAddress.anyIPv4, port)
		.then(
			(httpServer) => httpServer.listen((httpRequest) async {
				// dispatch httpRequest and generate a Request
				var request = Request(
					method: httpRequest.method,
					uri: httpRequest.uri,
					headers: httpRequest.headers,
					body: await utf8.decodeStream(httpRequest)
				);
				// handle the request
				var response = await router.onHandle(request);
				// generate response and send
				httpRequest.response.statusCode = response.statusCode;
				httpRequest.response.headers.clear();
				httpRequest.response.headers.contentType = response.contentType;
				httpRequest.response.headers.contentLength = response.body.length;
				response.headers.forEach((key, value) => httpRequest.response.headers.add(key, value));
				httpRequest.response.write(response.body);
				return httpRequest.response.close();
			})
		)
		.catchError((e) {
			Logger.error('SERVER', e);
		});
}

Middleware<T> _handleMiddlewareGet<T>(int index, Map<String, Middleware<T>> map, Endpoint endpoint) {
	var mw;
	if (T == Request) {
		mw = map[endpoint.requestMiddlewares[index]]!;
	} else { // T == Response
		mw = map[endpoint.responseMiddlewares[index]]!;
	}
	if (mw.singleton) {
		return mw;
	} else {
		var deepCopy = mw.clone();
		return deepCopy;
	}
}