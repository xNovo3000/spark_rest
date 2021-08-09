import 'dart:io';

import 'package:spark_rest/src/server/container/request.dart';

/// A convenience class that contains an HTTP response
class Response {

  /// Constructor
  const Response({
    required this.request,
    required this.statusCode,
    required this.headers,
    required this.contentType,
    required this.body,
  });

  /// The request that generated this response
  final Request request;

  /// The HTTP status code
  final int statusCode;

  /// The headers to append to the response
  final Map<String, dynamic> headers;

  /// The [ContentType] of the response
  final ContentType contentType;

  /// The body of the response
  final String body;

  @override
  bool operator ==(Object other) => other is Response ?
      request == other.request && statusCode == other.statusCode &&
      headers == other.headers && contentType == other.contentType &&
      body == other.body : false;

  @override
  int get hashCode => request.hashCode + statusCode.hashCode +
          headers.hashCode + contentType.hashCode + body.hashCode;

}
