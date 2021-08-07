import 'package:spark_rest/src/server/container/context.dart';

/// An interface for all initializable components
abstract class Initializable {
  /// Called to init a component only one time.
  ///
  /// Do not call this function, it is called from SparkREST from you.
  Future<void> onInit(final Context context);
}
