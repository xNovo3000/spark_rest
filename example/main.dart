import 'dart:io';

import 'package:spark_rest/spark_rest.dart';
import 'package:spark_rest/src/spark_rest_base.dart';

class TestRequestMiddleware extends Middleware<Request> {
  @override
  Future<Request> onHandle(Request param) async {
    param.container['test'] = 'My test variable';
    return param;
  }
}

class TestRootEndpoint extends Endpoint {
  @override
  Future<Response> onHandle(Request request) async {
    return Response(
      request: request,
      statusCode: 200,
      headers: {},
      contentType: ContentType.text,
      body: request.container['test'] ?? 'No variable',
    );
  }
}

class TestMiddlewarelessEndpoint extends Endpoint {
  @override
  Future<Response> onHandle(Request request) async {
    return Response(
      request: request,
      statusCode: 200,
      headers: {},
      contentType: ContentType.text,
      body: request.container['test'] ?? 'No variable',
    );
  }
}

class MyApplication extends Application {
  @override
  Future<void> onInit(Context context) async {
    registerEndpoint('/', Method.get, TestRootEndpoint());
    registerEndpoint('/test', Method.get, TestMiddlewarelessEndpoint());
    registerSingleMiddleware('/', Method.get,
        MiddlewareAttachType.whenUriHasBeenExtracted, TestRequestMiddleware());
    return super.onInit(context);
  }
}

Future main() => boot(application: MyApplication());
