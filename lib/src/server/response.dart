import 'dart:convert';
import 'dart:io';

import 'package:spark_http/src/server/request.dart';

class Response {

	factory Response.ok({
		required Request request,
		int statusCode = 200,
		ContentType? contentType,
		Map<String, dynamic> headers = const {},
		String? body,
	}) => Response(
		request: request,
		statusCode: statusCode,
		contentType: contentType ?? ContentType.json,
		headers: headers,
		body: body ?? ''
	);
	
	factory Response.error({
		required Request request,
		int statusCode = 501,
		Map<String, dynamic> headers = const {},
		String message = 'NOT_IMPLEMENTED',
	}) => Response(
		request: request,
		statusCode: statusCode,
		contentType: ContentType.json,
		headers: headers,
		body: json.encode({
			'message': message
		})
	);

	const Response({
		required this.request,
		required this.statusCode,
		required this.contentType,
		required this.headers,
		required this.body,
	});

	final Request request;
	final int statusCode;
	final ContentType contentType;
	final Map<String, dynamic> headers;
	final String body;

}