import 'package:spark_rest/src/server/foundation/context.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';

abstract class Middleware<T> implements Initializable, Handlable<T, T> {

  Middleware() : assert(T == Request || T == Response);

  @override
  Future<void> onInit(Context context) async => null;

  bool Function(String uri, Method method) get attachTo =>
      (uri, method) => false;

  void Function(List<Middleware<T>> list) get attachFunction =>
      (list) => list.add(clone ?? this);

  Middleware<T>? get clone => null;

}