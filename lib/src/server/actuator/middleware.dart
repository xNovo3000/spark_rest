import 'package:spark_rest/src/server/actuator/application.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';

abstract class Middleware<T> implements Initializable, Handlable<T, T> {
  @override
  Future<void> onInit(final Application application) async => null;

  bool Function(String? uri, Method? method) get attachTo =>
      (uri, method) => false;

  Middleware<T>? get clone => null;
}
