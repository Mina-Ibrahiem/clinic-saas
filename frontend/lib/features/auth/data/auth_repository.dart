import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/storage/session_storage.dart';
import '../domain/models/auth_user.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.read(apiClientProvider),
    sessionStorage: ref.read(sessionStorageProvider),
  );
});

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final loginResponse = await _apiClient.post<LoginResponse>(
      '/auth/login',
      data: LoginRequest(email: email, password: password).toJson(),
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid login response.');
        }
        return LoginResponse.fromJson(rawData);
      },
    );

    final payload = loginResponse.data;
    if (payload == null || payload.accessToken.isEmpty) {
      throw ApiException(message: 'Missing access token from login response.');
    }

    await _sessionStorage.saveToken(
      accessToken: payload.accessToken,
      tokenType: payload.tokenType,
    );

    final user = await me();
    await _sessionStorage.saveUser(user);
    return user;
  }

  Future<AuthUser> me() async {
    final response = await _apiClient.get<AuthUser>(
      '/auth/me',
      mapper: (rawData) {
        if (rawData is! Map<String, dynamic>) {
          throw ApiException(message: 'Invalid user profile response.');
        }
        return AuthUser.fromJson(rawData);
      },
    );

    final user = response.data;
    if (user == null) {
      throw ApiException(message: 'User profile is empty.');
    }
    await _sessionStorage.saveUser(user);
    return user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<Object?>(
        '/auth/logout',
        mapper: (_) => null,
      );
    } finally {
      await _sessionStorage.clearSession();
    }
  }

  Future<bool> refresh() async {
    try {
      final response = await _apiClient.post<Object?>(
        '/auth/refresh',
        mapper: (rawData) => rawData,
      );
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        return false;
      }
      final token = (payload['access_token'] as String?) ?? '';
      final tokenType = (payload['token_type'] as String?) ?? 'Bearer';
      if (token.isEmpty) return false;

      await _sessionStorage.saveToken(accessToken: token, tokenType: tokenType);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<AuthUser?> readCachedUser() => _sessionStorage.readUser();

  Future<String?> readAccessToken() => _sessionStorage.readAccessToken();
}
