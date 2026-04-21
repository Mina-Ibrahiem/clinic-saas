import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import '../storage/session_storage.dart';
import 'api_exception.dart';
import 'api_response.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage(ref.read(secureStorageServiceProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final sessionStorage = ref.read(sessionStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    _AuthInterceptor(
      sessionStorage: sessionStorage,
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );

  return ApiClient(dio);
});

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? data) mapper,
  }) async {
    return _send<T>(
      () => _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      ),
      mapper,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? data) mapper,
  }) async {
    return _send<T>(
      () => _dio.post<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
      mapper,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? data) mapper,
  }) async {
    return _send<T>(
      () => _dio.put<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
      mapper,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? data) mapper,
  }) async {
    return _send<T>(
      () => _dio.delete<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
      mapper,
    );
  }

  Future<ApiResponse<T>> _send<T>(
    Future<Response<Object?>> Function() request,
    T Function(Object? data) mapper,
  ) async {
    try {
      final response = await request();
      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw ApiException(
          message: 'Unexpected API response format.',
          statusCode: response.statusCode,
        );
      }

      final wrapped = ApiResponse<T>.fromJson(raw, mapper);
      if (!wrapped.success) {
        throw ApiException(
          message: wrapped.message.isEmpty ? 'Request failed.' : wrapped.message,
          statusCode: response.statusCode,
          errors: wrapped.errors,
        );
      }
      return wrapped;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  ApiException _mapDioError(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      return ApiException(
        message: (responseData['message'] as String?) ?? 'Request failed.',
        statusCode: error.response?.statusCode,
        errors: responseData['errors'],
      );
    }

    return ApiException(
      message: error.message ?? 'Network request failed.',
      statusCode: error.response?.statusCode,
    );
  }
}

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor({
    required SessionStorage sessionStorage,
    required String baseUrl,
  })  : _sessionStorage = sessionStorage,
        _baseUrl = baseUrl;

  final SessionStorage _sessionStorage;
  final String _baseUrl;
  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _sessionStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final requestPath = err.requestOptions.path;
    final wasRetried = err.requestOptions.extra['retried'] == true;
    final canRefresh = !requestPath.contains('/auth/login') && !requestPath.contains('/auth/refresh');

    if (!isUnauthorized || wasRetried || !canRefresh) {
      super.onError(err, handler);
      return;
    }

    final newToken = await _refreshToken();
    if (newToken == null) {
      super.onError(err, handler);
      return;
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      retryOptions.extra['retried'] = true;

      final response = await Dio(BaseOptions(baseUrl: _baseUrl)).fetch<Object?>(retryOptions);
      handler.resolve(response);
      return;
    } catch (_) {
      super.onError(err, handler);
      return;
    }
  }

  Future<String?> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();
    try {
      final currentToken = await _sessionStorage.readAccessToken();
      if (currentToken == null || currentToken.isEmpty) {
        _refreshCompleter!.complete(null);
        return _refreshCompleter!.future;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $currentToken',
          },
        ),
      );
      final response = await dio.post<Map<String, dynamic>>('/auth/refresh');
      final data = response.data;

      if (data == null || data['success'] != true) {
        await _sessionStorage.clearSession();
        _refreshCompleter!.complete(null);
        return _refreshCompleter!.future;
      }

      final payload = data['data'];
      if (payload is! Map<String, dynamic>) {
        await _sessionStorage.clearSession();
        _refreshCompleter!.complete(null);
        return _refreshCompleter!.future;
      }

      final accessToken = (payload['access_token'] as String?) ?? '';
      final tokenType = (payload['token_type'] as String?) ?? 'Bearer';
      if (accessToken.isEmpty) {
        await _sessionStorage.clearSession();
        _refreshCompleter!.complete(null);
        return _refreshCompleter!.future;
      }

      await _sessionStorage.saveToken(
        accessToken: accessToken,
        tokenType: tokenType,
      );
      _refreshCompleter!.complete(accessToken);
      return _refreshCompleter!.future;
    } catch (_) {
      await _sessionStorage.clearSession();
      _refreshCompleter!.complete(null);
      return _refreshCompleter!.future;
    } finally {
      _refreshCompleter = null;
    }
  }
}
