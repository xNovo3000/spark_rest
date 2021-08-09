import 'dart:io';

import 'package:spark_rest/spark_rest.dart';

class RootEndpoint extends Endpoint {

  RootEndpoint() : super(
    uri: '/',
    method: Method.get,
  );

  @override
  Future<Response> onHandle(Request request) async {
    return Response(
      request: request,
      statusCode: 200,
      headers: {},
      contentType: ContentType.text,
      body: request.container['Test'] ?? 'No var',
    );
  }

}

class TestEndpoint extends Endpoint {

  TestEndpoint() : super(
    uri: '/test',
    method: Method.get,
  );

  @override
  Future<Response> onHandle(Request request) async {
    return Response(
      request: request,
      statusCode: 200,
      headers: {},
      contentType: ContentType.text,
      body: request.container['Test'] ?? 'No var',
    );
  }

}

class MyRequestMiddleware extends Middleware<Request> {

  @override
  Future<void> onInit(Context context) async {
    print(MethodRouter.of(context, '/test'));
  }

  @override
  Future<Request> onHandle(Request request) async {
    request.container['Test'] = 'Test';
    return request;
  }

  @override
  bool Function(String uri, Method method) get attachTo =>
      (uri, method) => uri == '/';

}

class MyPlugin extends Plugin {

  @override
  Iterable<Middleware<Request>> get requestMiddlewares =>
      [MyRequestMiddleware()];

}

Future main() => boot(application: Application(
  requestMiddlewares: [],
  endpoints: [RootEndpoint(), TestEndpoint()],
  plugins: [MyPlugin()]
));
