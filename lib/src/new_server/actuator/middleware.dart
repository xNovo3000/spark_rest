import 'package:spark_rest/src/new_server/interface/handlable.dart';
import 'package:spark_rest/src/new_server/interface/initializable.dart';

abstract class Middleware<R, P> implements Initializable, Handlable<R, P> {

  @override
  Future<void> onInit() async => null;

  Middleware<R, P> get clone => throw UnimplementedError('$runtimeType: the clone getter should be always implemented');

}