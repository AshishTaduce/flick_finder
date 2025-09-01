import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add smart retry interceptor
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: kDebugMode ? print : null,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          // Retry on connection errors, timeouts, and 5xx server errors
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            if (kDebugMode) {
              print('Retrying request due to ${error.type} (attempt $attempt)');
            }
            return true;
          }
          
          // Retry on server errors (5xx) and some 4xx errors
          if (error.response?.statusCode != null) {
            final statusCode = error.response!.statusCode!;
            // Retry on server errors (5xx) and rate limiting (429)
            if ((statusCode >= 500 && statusCode < 600) || statusCode == 429) {
              if (kDebugMode) {
                print('Retrying request due to status code $statusCode (attempt $attempt)');
              }
              return true;
            }
          }
          
          return false;
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['api_key'] = ApiConstants.apiKey;
          if (kDebugMode) {
            debugPrint('Request: ${options.method} ${options.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              'Response: ${response.statusCode} ${response.requestOptions.path}',
            );
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('Error: ${error.message}');
            debugPrint('Error type: ${error.type}');
            debugPrint('Status code: ${error.response?.statusCode}');
            debugPrint('Request path: ${error.requestOptions.path}');
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
