import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/auth_token_storage.dart';
import 'api_exception.dart';

/// Thin wrapper around Dio, centralizing base URL, timeouts, auth header
/// injection, and error translation into our own ApiException type. Every
/// feature's data layer goes through THIS class rather than creating its
/// own Dio instance — one place to handle auth, logging, or retry logic
/// without touching every feature module individually.
class ApiClient {
  late final Dio _dio;

  ApiClient(AuthTokenStorage tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Attach the saved access token (if any) to every outgoing request.
    // Reading from storage per-request means a login/logout takes effect
    // immediately, with no need to rebuild or re-configure this client.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  /// For endpoints whose JSON response is a single object.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// For endpoints whose JSON response is an array at the TOP level, like
  /// our leaderboard endpoints. Using `get()` for these would throw a
  /// runtime cast error, since a List can't be cast to Map<String, dynamic>.
  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    // Nest's validation errors arrive as a LIST of messages (one per failed
    // rule); other errors arrive as a single string. Join lists so the UI
    // shows readable lines instead of "[msg one, msg two]".
    final rawMessage = responseData is Map ? responseData['message'] : null;
    final serverMessage = rawMessage is List
        ? rawMessage.join('\n')
        : rawMessage?.toString();

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiException('Request timed out. Check your connection.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(
        'Could not reach the server. Is the backend running?',
      );
    }

    return ApiException(
      serverMessage ?? 'Something went wrong. Please try again.',
      statusCode: statusCode,
    );
  }
}
