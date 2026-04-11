import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

class ApiConfig {
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(milliseconds: 500);

  static const String defaultUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static Dio createDio({
    String? baseUrl,
    Map<String, dynamic>? headers,
    bool enableGzip = true,
    bool useNativeAdapter = true,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          'user-agent': defaultUserAgent,
          'Accept': '*/*',
          if (enableGzip) 'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          ...?headers,
        },
        validateStatus: (status) => status != null && status < 500,
        responseType: ResponseType.plain,
      ),
    );

    if (!kIsWeb && useNativeAdapter) {
      if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
        dio.httpClientAdapter = NativeAdapter();
      }
    }

    dio.interceptors.add(RetryInterceptor(dio: dio));
    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }

  static void setProxy(Dio dio, String proxyIP) {
    if (kIsWeb) return;

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) => 'PROXY $proxyIP';
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = ApiConfig.maxRetries,
    this.retryDelay = ApiConfig.retryDelay,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] as int? ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      await Future<void>.delayed(
        Duration(milliseconds: retryDelay.inMilliseconds * (retryCount + 1)),
      );

      final options = err.requestOptions;
      options.extra['retryCount'] = retryCount + 1;

      try {
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500 &&
            err.response!.statusCode! < 600);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final enhancedError = _enhanceError(err);
    handler.next(enhancedError);
  }

  DioException _enhanceError(DioException err) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = '連線逾時，請檢查網路狀態';
      case DioExceptionType.sendTimeout:
        message = '發送請求逾時';
      case DioExceptionType.receiveTimeout:
        message = '接收回應逾時';
      case DioExceptionType.badCertificate:
        message = '憑證驗證失敗';
      case DioExceptionType.badResponse:
        message = _getResponseErrorMessage(err.response?.statusCode);
      case DioExceptionType.cancel:
        message = '請求已取消';
      case DioExceptionType.connectionError:
        message = '網路連線錯誤，請檢查網路狀態';
      case DioExceptionType.unknown:
        message = err.error?.toString() ?? '發生未知錯誤';
    }

    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: err.error,
      message: message,
    );
  }

  String _getResponseErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '請求參數錯誤';
      case 401:
        return '未授權，請重新登入';
      case 403:
        return '存取被拒絕';
      case 404:
        return '請求的資源不存在';
      case 408:
        return '請求逾時';
      case 429:
        return '請求過於頻繁，請稍後再試';
      case 500:
        return '伺服器內部錯誤';
      case 502:
        return '閘道錯誤';
      case 503:
        return '服務暫時不可用';
      case 504:
        return '閘道逾時';
      default:
        return '伺服器錯誤 ($statusCode)';
    }
  }
}

extension DioExtensions on Dio {
  Future<Response<T>> safeGet<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response<T>> safePost<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException {
      rethrow;
    }
  }
}
