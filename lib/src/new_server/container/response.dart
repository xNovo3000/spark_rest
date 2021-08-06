import 'package:spark_rest/src/new_server/container/request.dart';

class Response {

  const Response({
    required this.request,
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  final Request request;
  final int statusCode;
  final Map<String, dynamic> headers;
  final String body;

  @override
  bool operator ==(Object other) => other is Response ?
    request == other.request && statusCode == other.statusCode &&
    headers == other.headers && body == other.body : false;

  @override
  int get hashCode => request.hashCode + statusCode.hashCode + headers.hashCode + body.hashCode;

}