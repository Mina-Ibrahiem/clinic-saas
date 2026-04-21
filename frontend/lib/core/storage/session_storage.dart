import 'dart:convert';

import '../../features/auth/domain/models/auth_user.dart';
import 'secure_storage_service.dart';

class SessionStorage {
  SessionStorage(this._secureStorage);

  static const _accessTokenKey = 'session.access_token';
  static const _tokenTypeKey = 'session.token_type';
  static const _userKey = 'session.user_json';

  final SecureStorageService _secureStorage;

  Future<void> saveToken({
    required String accessToken,
    required String tokenType,
  }) async {
    await _secureStorage.write(_accessTokenKey, accessToken);
    await _secureStorage.write(_tokenTypeKey, tokenType);
  }

  Future<String?> readAccessToken() => _secureStorage.read(_accessTokenKey);

  Future<String> readTokenType() async => (await _secureStorage.read(_tokenTypeKey)) ?? 'Bearer';

  Future<void> saveUser(AuthUser user) async {
    await _secureStorage.write(_userKey, jsonEncode(user.toJson()));
  }

  Future<AuthUser?> readUser() async {
    final raw = await _secureStorage.read(_userKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return AuthUser.fromJson(decoded);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(_accessTokenKey);
    await _secureStorage.delete(_tokenTypeKey);
    await _secureStorage.delete(_userKey);
  }
}
