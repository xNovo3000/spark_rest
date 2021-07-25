import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spark_http/src/generator/chain_generator.dart';
import 'package:spark_http/src/server/middleware.dart';
import 'package:spark_http/src/addon/plugin.dart';
import 'package:spark_http/src/server/request.dart';
import 'package:spark_http/src/server/response.dart';
import 'package:spark_http/src/server/router.dart';

Future boot({
	int port = 8080,
	Map<String, Middleware<Request>> requestMiddlewares = const {},
	Map<String, Middleware<Response>> responseMiddlewares = const {},
	List<ChainGenerator> endpoints = const [],
	List<Plugin> plugins = const [],
}) async {
	// TODO: add plugin handle
	// generate the router and populate
	final router = Router();
	for (var ep in endpoints) {
		router.appendRoute(
			method: ep.method,
			route: ep.uri,
			endpoint: ep.endpoint,
			requestMiddlewares: List.generate(
				ep.requestMiddlewares.length,
				(index) => requestMiddlewares[ep.requestMiddlewares[index]]!,
				growable: false
			),
			responseMiddlewares: List.generate(
				ep.responseMiddlewares.length,
				(index) => responseMiddlewares[ep.responseMiddlewares[index]]!,
				growable: false
			),
		);
	}
	// generate the server
	return HttpServer.bind(InternetAddress.anyIPv4, port).then(
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
	).catchError((e) {print(e);});
}