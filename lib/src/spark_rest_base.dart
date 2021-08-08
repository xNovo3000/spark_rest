import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spark_rest/src/server/actuator/application.dart';
import 'package:spark_rest/src/server/container/method.dart';
import 'package:spark_rest/src/server/container/request.dart';

/// Function used to run a Spark server
Future boot({
  required Application application,
  int port = 8080,
}) =>
    HttpServer.bind(InternetAddress.anyIPv4, port).then((server) async {
      await application.onInit(application.context);
      server.listen((httpRequest) async {
        var request = Request(
            method: Method.fromValue(httpRequest.method),
            uri: httpRequest.uri,
            headers: httpRequest.headers,
            body: await utf8.decodeStream(httpRequest),
            container: {});
        var response = await application.onHandle(request);
        httpRequest.response.statusCode = response.statusCode;
        httpRequest.response.headers.clear();
        httpRequest.response.headers.contentType = response.contentType;
        httpRequest.response.headers.contentLength = response.body.length;
        response.headers.forEach(
            (key, value) => httpRequest.response.headers.add(key, value));
        httpRequest.response.write(response.body);
        return httpRequest.response.close();
      });
    });
