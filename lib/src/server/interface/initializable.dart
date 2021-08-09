import 'package:spark_rest/src/server/foundation/context.dart';

/// Convenience class for all initializable objects
abstract class Initializable {

  /// Method called to initialize this class
  Future<void> onInit(Context context);

}
