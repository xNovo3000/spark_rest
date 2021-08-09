import 'package:spark_rest/src/server/foundation/context.dart';

abstract class Initializable {

  Future<void> onInit(Context context);

}
