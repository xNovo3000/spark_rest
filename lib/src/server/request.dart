import 'dart:io';

class Request {

	const Request({
		required this.method,
		required this.uri,
		required this.headers,
		required this.body,
		this.data = const {}
	});

	final String method;
	final Uri uri;
	final HttpHeaders headers;
	final String body;
	final Map<String, dynamic> data;

}