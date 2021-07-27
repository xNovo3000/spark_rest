import 'dart:io';

import 'package:spark_http/spark_http.dart';

class RootReqMw extends Middleware<Request> {

	@override
	Future<Request> onHandle(Request data) async {
		data.data['test'] = 'test';
		return data;
	}

}

class RootEp extends Endpoint {

	RootEp() : super(
		method: 'GET',
		uri: '/',
		requestMiddlewares: ['root']
	);

	@override
	Future<Response> onHandle(Request request) async {
		print(request.data.length);
		return Response.ok(
			request: request,
			contentType: ContentType.text,
			body: 'Weee',
		);
	}
	
}

Future main() => boot(
	requestMiddlewares: {
		'root': RootReqMw(),
	},
	endpoints: [
		RootEp(),
	]
);