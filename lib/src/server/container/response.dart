import 'dart:io';

import 'package:spark_rest/src/server/container/request.dart';

class Response {
  const Response({
    required this.request,
    required this.statusCode,
    required this.headers,
    required this.contentType,
    required this.body,
  });

  final Request request;
  final int statusCode;
  final Map<String, dynamic> headers;
  final ContentType contentType;
  final String body;

  @override
  bool operator ==(Object other) => other is Response
      ? request == other.request &&
          statusCode == other.statusCode &&
          headers == other.headers &&
          contentType == other.contentType &&
          body == other.body
      : false;

  @override
  int get hashCode =>
      request.hashCode +
      statusCode.hashCode +
      headers.hashCode +
      contentType.hashCode +
      body.hashCode;
}
