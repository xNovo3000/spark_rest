import 'dart:convert';
import 'dart:io';

import 'package:spark_http/spark_http.dart' as spark;
import 'package:spark_http/src/generator/chain_generator.dart';
import 'package:spark_http/src/server/endpoint.dart';
import 'package:spark_http/src/server/response.dart';
import 'package:spark_http/src/server/request.dart';

class RootEndpoint extends Endpoint {
	
	@override
	Future<Response> onHandle(Request request) async {
		return Response.ok(
			request: request,
			body: 'Test',
			contentType: ContentType.text
		);
	}

}

class JsonEndpoint extends Endpoint {
	
	@override
	Future<Response> onHandle(Request request) async {
		return Response.ok(
			request: request,
			body: json.encode({
				'test': true
			}),
			contentType: ContentType.json
		);
	}

}

Future main() => spark.boot(
	endpoints: [
		ChainGenerator(
			method: 'GET',
			uri: '/',
			endpoint: RootEndpoint(),
		),
		ChainGenerator(
			method: 'GET',
			uri: '/test',
			endpoint: JsonEndpoint(),
		),
	]
);