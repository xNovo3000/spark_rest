import 'package:spark_rest/src/server/container/context.dart';

abstract class Initializable {
  Future<void> onInit(final Context context);
}
