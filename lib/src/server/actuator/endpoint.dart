import 'package:spark_rest/src/server/container/context.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';

/// A class that responds for a single HTTP method and a single HTTP uri
///
/// Example: "GET /test HTTP/1.1" and "POST /test HTTP/1.1"
/// are two different endpoints
abstract class Endpoint implements Initializable, Handlable<Response, Request> {
  @override
  Future<void> onInit(final Context context) async => null;
}
