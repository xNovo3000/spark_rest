import 'package:spark_rest/src/abstract_server/foundation/context.dart';

abstract class Initializable {

  Future<void> onInit(Context context);

}
