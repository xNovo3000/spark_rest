import 'package:spark_rest/src/new_server/interface/handlable.dart';
import 'package:spark_rest/src/new_server/interface/initializable.dart';

abstract class Middleware<T> implements Initializable, Handlable<T, T> {
  @override
  Future<void> onInit() async => null;

  Middleware<T>? get clone => null;
}
