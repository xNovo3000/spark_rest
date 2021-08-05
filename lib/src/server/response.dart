import 'dart:convert';
import 'dart:io';

import 'package:spark_rest/src/server/request.dart';

/// An easy-to-use container for responses
class Response {

	/// Generates a successful response
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
	
	/// Generates a non successful response
	/// 
	/// This type of response is being sent with an error [message]. Example:
	/// json'''
	/// {
	/// 		"message": "My custom error message"
	/// }
	/// '''
	factory Response.error({
		required Request request,
		int statusCode = 501,
		Map<String, dynamic> headers = const {},
		String message = 'This function has not been implemented',
	}) => Response(
		request: request,
		statusCode: statusCode,
		contentType: ContentType.json,
		headers: headers,
		body: json.encode({
			'message': message
		})
	);

	/// Constructor
	const Response({
		required this.request,
		required this.statusCode,
		required this.contentType,
		required this.headers,
		required this.body,
	});

	/// The generating request
	final Request request;

	/// The resulting HTTP status code
	final int statusCode;

	/// The Content-Type of the response body
	final ContentType contentType;

	/// The headers attached to the response
	final Map<String, dynamic> headers;

	/// The body of the response
	final String body;

}