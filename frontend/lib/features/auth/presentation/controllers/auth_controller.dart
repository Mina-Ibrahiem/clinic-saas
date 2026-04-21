import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/api_exception.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/auth_user.dart';

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(ref)..bootstrap();
});

class AuthController extends ChangeNotifier {
  AuthController(this._ref);

  final Ref _ref;

  bool initialized = false;
  bool loading = false;
  String? errorMessage;
  AuthUser? user;

  bool get isAuthenticated => user != null;

  Future<void> bootstrap() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final repository = _ref.read(authRepositoryProvider);
      final token = await repository.readAccessToken();
      if (token == null || token.isEmpty) {
        user = null;
      } else {
        try {
          user = await repository.me();
        } catch (_) {
          await repository.logout();
          user = null;
        }
      }
    } finally {
      initialized = true;
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          );
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Unable to sign in right now. Please try again.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    loading = true;
    notifyListeners();

    try {
      await _ref.read(authRepositoryProvider).logout();
      user = null;
      errorMessage = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
