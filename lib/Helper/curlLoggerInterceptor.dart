import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

/// Logs http.MultipartRequest as cURL command
/// Use this for requests made with the http package instead of Dio
void logHttpMultipartRequestAsCurl(http.MultipartRequest request) {
  final method = request.method.toUpperCase();
  final url = request.url.toString();
  final headers = request.headers;
  final fields = request.fields;
  final files = request.files;

  var curlCommand = "curl -X $method '$url'";

  // Add headers
  headers.forEach((key, value) {
    curlCommand += " -H '$key: $value'";
  });

  // Add form fields
  fields.forEach((key, value) {
    curlCommand += " -F '$key=$value'";
  });

  // Add files
  for (final file in files) {
    curlCommand += " -F '${file.field}=@${file.filename ?? 'file'}'";
  }

  // Use developer.log() to remove "I/flutter"
  developer.log(
    '\n🔍 cURL Request:\n           $curlCommand\n',
    name: 'CURL_LOG',
  );
}

class CurlLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final url = options.uri.toString();
    final headers = options.headers;
    final data = options.data;

    var curlCommand = "curl -X $method '$url'";

    // Add headers
    headers.forEach((key, value) {
      curlCommand += " -H '$key: $value'";
    });

    // Handle FormData correctly
    if (data != null) {
      if (data is FormData) {
        // Convert FormData fields to cURL format
        for (final field in data.fields) {
          curlCommand += " -F '${field.key}=${field.value}'";
        }

        // Convert files in FormData
        for (final file in data.files) {
          curlCommand += " -F '${file.key}=@${file.value.filename}'";
        }
      } else if (data is Map || data is List) {
        // Convert JSON to FormData format
        data.forEach((key, value) {
          curlCommand += " -F '$key=$value'";
        });
      } else {
        curlCommand += " -F 'body=$data'";
      }
    }

    // Use developer.log() to remove "I/flutter"
    developer.log('\n🔍 cURL Request:\n$curlCommand\n', name: 'CURL_LOG');

    handler.next(options);
  }
}
