import 'package:spark_rest/src/server/actuator/application.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';

abstract class Endpoint implements Initializable, Handlable<Response, Request> {
  @override
  Future<void> onInit(final Application application) async => null;
}
