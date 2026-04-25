import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eshop_multivendor/Helper/curlLoggerInterceptor.dart';
import 'package:eshop_multivendor/Helper/sessionManager.dart';
import 'package:eshop_multivendor/main.dart';
import '../widgets/security.dart';
import 'Constant.dart';

import 'package:dio/dio.dart' as dio_;

class ApiException implements Exception {
  ApiException(this.errorMessage);

  String errorMessage;

  @override
  String toString() {
    return errorMessage;
  }
}

class ApiBaseHelper {
  //To download the attachment, using the dio
  Future<void> downloadFile({
    required String url,
    required dio_.CancelToken cancelToken,
    required String savePath,
    required Function updateDownloadedPercentage,
  }) async {
    try {
      final dio_.Dio dio = dio_.Dio();
      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: ((count, total) {
          updateDownloadedPercentage((count / total) * 100);
        }),
      );
    } on dio_.DioException catch (e) {
      if (e.type == dio_.DioExceptionType.connectionError) {
        throw ApiException('No Internet connection');
      }

      throw ApiException('Failed to download file');
    } catch (e) {
      throw Exception('Failed to download file');
    }
  }

  Future<dynamic> postAPICall(Uri url, Map? param) async {
    try {
      final Dio dio = Dio();
      dio.interceptors.add(CurlLoggerInterceptor());

      // Use Dio to make the request with the interceptor
      final dioResponse = await dio
          .post(
            url.toString(),
            data: param?.isEmpty ?? true ? null : param,
            options: dio_.Options(
              headers: headers,
              contentType: 'application/x-www-form-urlencoded',
            ),
          )
          .timeout(const Duration(seconds: timeOut));

      final res = await _responseDio(dioResponse);
      if (res == null) return {};
      return res;
    } on dio_.DioException catch (e) {
      if (e.type == dio_.DioExceptionType.connectionError) {
        throw ApiException('No Internet connection');
      } else if (e.type == dio_.DioExceptionType.connectionTimeout ||
          e.type == dio_.DioExceptionType.receiveTimeout) {
        throw ApiException('Something went wrong, Server not Responding');
      }
      throw ApiException('Something Went wrong with ${e.message}');
    } on SocketException {
      throw ApiException('No Internet connection');
    } on TimeoutException {
      throw ApiException('Something went wrong, Server not Responding');
    } on Exception catch (e) {
      throw ApiException('Something Went wrong with ${e.toString()}');
    }
  }

  dynamic _responseDio(dio_.Response response) async {
    switch (response.statusCode) {
      case 200:
        // Dio already parses JSON if the response is JSON
        if (response.data is String) {
          return json.decode(response.data);
        }
        return response.data;

      case 401:
      case 103:
        // Account deactivated
        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          await SessionManager.forceLogout(ctx);
        }
        return null;

      case 400:
        throw BadRequestException(response.data.toString());

      case 403:
        throw UnauthorisedException(response.data.toString());

      case 500:
      default:
        throw FetchDataException(
          'Error occurred while Communication with Server with StatusCode: ${response.statusCode}',
        );
    }
  }
}

class CustomException implements Exception {
  final message;
  final prefix;

  CustomException([this.message, this.prefix]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([message])
    : super(message, 'Error During Communication: ');
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, 'Invalid Request: ');
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, 'Unauthorised: ');
}

class InvalidInputException extends CustomException {
  InvalidInputException([message]) : super(message, 'Invalid Input: ');
}
