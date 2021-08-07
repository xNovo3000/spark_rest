import 'package:spark_rest/src/server/actuator/application.dart';

abstract class Initializable {
  Future<void> onInit(final Application application);
}
