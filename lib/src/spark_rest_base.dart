import 'dart:io';
import 'dart:convert';

import 'package:spark_rest/spark_rest.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/container/request.dart';
import 'package:spark_rest/src/server/foundation/context.dart';
import 'package:spark_rest/src/server/foundation/application.dart';

/// Function used to run a Spark server
Future boot({
  required Application application,
  int port = 8080,
}) =>
    HttpServer.bind(InternetAddress.anyIPv4, port).then((server) async {
      var context = Context();
      var uriRouter = UriRouter();
      context.register(uriRouter);
      await application.onInit(context);
      server.listen((httpRequest) async {
        var request = Request(
          method: Method.fromValue(httpRequest.method),
          uri: httpRequest.uri,
          headers: httpRequest.headers,
          body: await utf8.decodeStream(httpRequest),
          container: {}
        );
        var response = await application.onHandle(request);
        httpRequest.response.statusCode = response.statusCode;
        httpRequest.response.headers.clear();
        httpRequest.response.headers.contentType = response.contentType;
        httpRequest.response.headers.contentLength = response.body.length;
        response.headers.forEach(
          (key, value) => httpRequest.response.headers.add(key, value)
        );
        httpRequest.response.write(response.body);
        return httpRequest.response.close();
      });
    });
