// lib/core/network/api_client.dart

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import 'token_storage.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage tokenStorage;
  final _unauthorizedController = StreamController<void>.broadcast();

  Stream<void> get unauthorizedEvents => _unauthorizedController.stream;

  ApiClient({required this.tokenStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Interceptor: Inject token ke setiap request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Auto logout jika token expired/invalid
          if (error.response?.statusCode == 401) {
            await tokenStorage.deleteToken();
            _unauthorizedController.add(null);
          }
          return handler.next(error);
        },
      ),
    );

    // Logger — hanya aktif di debug mode
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );
  }

  /// Konversi DioException menjadi Failure yang konsisten
  Failure handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkFailure();
    }

    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (statusCode == 401) {
      return UnauthorizedFailure();
    }

    if (statusCode == 422) {
      final errors = data is Map && data['errors'] != null
          ? Map<String, List<String>>.from(
              (data['errors'] as Map).map(
                (k, v) => MapEntry(k.toString(), List<String>.from(v)),
              ),
            )
          : null;

      return ValidationFailure(
        message: data is Map && data['message'] != null
            ? data['message']
            : 'Validasi gagal.',
        errors: errors,
      );
    }

    return ServerFailure(
      message: data is Map && data['message'] != null
          ? data['message']
          : 'Terjadi kesalahan pada server.',
      statusCode: statusCode,
    );
  }

  void dispose() {
    _unauthorizedController.close();
  }
}
