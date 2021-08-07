import 'package:spark_rest/src/new_server/container/request.dart';
import 'package:spark_rest/src/new_server/container/response.dart';
import 'package:spark_rest/src/new_server/interface/handlable.dart';
import 'package:spark_rest/src/new_server/interface/initializable.dart';

abstract class Endpoint implements Initializable, Handlable<Response, Request> {
  @override
  Future<void> onInit() async => null;
}
