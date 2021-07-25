import 'package:spark_http/src/server/request.dart';
import 'package:spark_http/src/server/response.dart';

abstract class Endpoint {

	Future<Response> onHandle(final Request request);
	
}