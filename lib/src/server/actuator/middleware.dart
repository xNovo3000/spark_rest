import 'package:spark_rest/src/server/container/context.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';

/// Used to manage requests and responses before and after the endpoint manages them
abstract class Middleware<T> implements Initializable, Handlable<T, T> {
  @override
  Future<void> onInit(final Context context) async => null;

  /// Indicates for which uris and methods the middleware should attach to
  ///
  /// It is used only with if you are attempting to register
  /// this middleware in widespread mode.
  bool Function(String? uri, Method? method) get attachTo =>
      (uri, method) => false;

  /// A clone of this class
  ///
  /// Override this method only if you want to have different instances
  /// for each middleware in your tree
  Middleware<T>? get clone => null;
}
