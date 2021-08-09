import 'package:spark_rest/src/server/foundation/context.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/container/response.dart';
import 'package:spark_rest/src/server/interface/handlable.dart';
import 'package:spark_rest/src/server/interface/initializable.dart';

/// A class that responds to a single [Uri] and a single [Method]
abstract class Endpoint implements Initializable, Handlable<Request, Response> {
  /// Constructor
  const Endpoint({
    required this.uri,
    required this.method,
  });

  /// The [Uri] the class must respond to
  final String uri;

  /// The [Method] the class must respond to
  final Method method;

  @override
  Future<void> onInit(Context context) async => null;
}
