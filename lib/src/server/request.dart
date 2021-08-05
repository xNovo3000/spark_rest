import 'dart:io';

/// An easy-to-use container for requests
class Request {

	/// Constructor
	/// 
	/// A request is generated from Spark. Do not generate custom requests
	Request({
		required this.method,
		required this.uri,
		required this.headers,
		required this.body,
	}) : data = {};

	/// The accepted HTTP method
	final String method;
	
	/// The requested full [Uri]
	final Uri uri;

	/// The headers of the request
	final HttpHeaders headers;
	
	/// The body of the request
	/// 
	/// The body is always a [String]. It is up to you to dispatch.
	final String body;

	/// This contains a list of data that can be shared between middlewares and endpoints
	/// 
	/// Example: the middleware logged in the user and the endpoint must know that
	/// the user has been logged in
	final Map<String, dynamic> data;

}