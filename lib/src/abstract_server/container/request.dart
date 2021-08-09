import 'dart:io';

import 'package:spark_rest/src/abstract_server/container/method.dart';

/// A convenience class that contains an HTTP request
class Request {

  /// Constructor
  const Request({
    required this.uri,
    required this.method,
    required this.headers,
    required this.body,
    required this.container,
  });

  /// The [Uri] of the request
  final Uri uri;

  /// The [Method] of the request
  final Method method;

  /// The headers of the request
  final HttpHeaders headers;

  /// The body of the request
  final String body;

  /// A container for all variables
  ///
  /// It is used to communicate between middlewares and endpoints
  final Map<String, dynamic> container;

  @override
  bool operator ==(Object other) => other is Request ?
      uri == other.uri && method == other.method &&
      headers == other.headers && body == other.body : false;

  @override
  int get hashCode => uri.hashCode + method.hashCode +
      headers.hashCode + body.hashCode;

}
