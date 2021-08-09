import 'package:spark_rest/src/abstract_server/foundation/context.dart';
import 'package:spark_rest/src/abstract_server/container/method.dart';
import 'package:spark_rest/src/abstract_server/container/request.dart';
import 'package:spark_rest/src/abstract_server/container/response.dart';
import 'package:spark_rest/src/abstract_server/interface/handlable.dart';
import 'package:spark_rest/src/abstract_server/interface/initializable.dart';

abstract class Endpoint implements Initializable, Handlable<Request, Response> {

  const Endpoint({
    required this.uri,
    required this.method,
  });

  final String uri;
  final Method method;

  @override
  Future<void> onInit(Context context) async => null;

}