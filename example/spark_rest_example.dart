import 'dart:io';

import 'package:spark_rest/spark_rest.dart';

class RootReqMw extends Middleware<Request> {

	@override
	Future<Request> onHandle(Request data) async {
		data.data['test'] = 'test';
		return data;
	}

	@override
	Future<void> onInit(String uri, String method) async {
		print('loaded middleware one time');
	}

	@override
  bool Function(String method, String uri) get appendOverride => (method, uri) => true;

}

class RootEp extends Endpoint {

	RootEp() : super(
		method: 'GET',
		uri: '/',
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

Future main() => sparkBoot(
	requestMiddlewares: {
		'root': RootReqMw(),
	},
	endpoints: [
		RootEp(),
	]
);