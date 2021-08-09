import 'package:spark_rest/src/server/foundation/context.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';

abstract class Middleware<T> implements Initializable, Handlable<T, T> {

  /// Constructor
  ///
  /// Ensures that [T] is always a [Request] or a [Response]
  Middleware() : assert(T == Request || T == Response);

  @override
  Future<void> onInit(Context context) async => null;

  /// Function used to check if this [Middleware] should attach
  /// to a request chain defined uri and method
  bool Function(String uri, Method method) get attachTo =>
      (uri, method) => false;

  /// Function used to attach a [Middleware] to a request chain
  void Function(List<Middleware<T>> list) get attachFunction =>
      (list) => list.add(clone ?? this);

  /// Returns a shallow copy of this object
  ///
  /// If you don't want to use the same [Middleware] instance for
  /// every attachment, then override this method
  Middleware<T>? get clone => null;

}