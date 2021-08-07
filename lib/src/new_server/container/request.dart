import 'dart:io';

import 'package:spark_rest/src/new_server/container/method.dart';

class Request {
  const Request({
    required this.uri,
    required this.method,
    required this.headers,
    required this.body,
    required this.container,
  });

  final Uri uri;
  final Method method;
  final HttpHeaders headers;
  final String body;
  final Map<String, dynamic> container;

  @override
  bool operator ==(Object other) => other is Request
      ? uri == other.uri &&
          method == other.method &&
          headers == other.headers &&
          body == other.body
      : false;

  @override
  int get hashCode =>
      uri.hashCode + method.hashCode + headers.hashCode + body.hashCode;
}
