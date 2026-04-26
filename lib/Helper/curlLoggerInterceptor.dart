import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Logs http.MultipartRequest as cURL — DEBUG builds only.
void logHttpMultipartRequestAsCurl(http.MultipartRequest request) {
  if (!kDebugMode) return;

  final method = request.method.toUpperCase();
  final url = request.url.toString();
  final headers = request.headers;
  final fields = request.fields;
  final files = request.files;

  var curlCommand = "curl -X $method '$url'";

  headers.forEach((key, value) {
    // Redact Authorization header value to avoid token leaks in logs
    final safeValue = key.toLowerCase() == 'authorization' ? '[REDACTED]' : value;
    curlCommand += " -H '$key: $safeValue'";
  });

  fields.forEach((key, value) {
    curlCommand += " -F '$key=$value'";
  });

  for (final file in files) {
    curlCommand += " -F '\${file.field}=@\${file.filename ?? 'file'}'";
  }

  developer.log(
    '\n🔍 cURL Request:\n           $curlCommand\n',
    name: 'CURL_LOG',
  );
}

class CurlLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final method = options.method.toUpperCase();
      final url = options.uri.toString();
      final headers = options.headers;
      final data = options.data;

      var curlCommand = "curl -X $method '$url'";

      headers.forEach((key, value) {
        // Redact Authorization to prevent token leaks in logs
        final safeValue =
            key.toLowerCase() == 'authorization' ? '[REDACTED]' : value;
        curlCommand += " -H '$key: $safeValue'";
      });

      if (data != null) {
        if (data is FormData) {
          for (final field in data.fields) {
            curlCommand += " -F '\${field.key}=\${field.value}'";
          }
          for (final file in data.files) {
            curlCommand += " -F '\${file.key}=@\${file.value.filename}'";
          }
        } else if (data is Map || data is List) {
          data.forEach((key, value) {
            curlCommand += " -F '$key=$value'";
          });
        } else {
          curlCommand += " -F 'body=$data'";
        }
      }

      developer.log('\n🔍 cURL Request:\n$curlCommand\n', name: 'CURL_LOG');
    }

    handler.next(options);
  }
}
