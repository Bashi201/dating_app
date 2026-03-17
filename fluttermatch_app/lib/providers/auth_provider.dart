import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

// State notifier
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
      return AuthNotifier(ref.read(authServiceProvider));
    });

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  // Check if token exists on app launch
  Future<void> _init() async {
    try {
      final token = await SecureStorage.getToken();
      if (token != null) {
        final user = await _service.getMe();
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (_) {
      // Token invalid or expired
      await SecureStorage.deleteToken();
      state = const AsyncValue.data(null);
    }
  }

  // ─── Register ─────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _service.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await SecureStorage.saveToken(result.token);
      return result.user;
    });
  }

  // ─── Login ────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _service.login(email: email, password: password);
      await SecureStorage.saveToken(result.token);
      return result.user;
    });
  }

  // ─── Logout ───────────────────────────────────────
  Future<void> logout() async {
    await _service.logout();
    state = const AsyncValue.data(null);
  }

  // ─── Refresh User ─────────────────────────────────
  Future<void> refreshUser() async {
    try {
      final user = await _service.getMe();
      state = AsyncValue.data(user);
    } catch (_) {
      // Silently fail — auth state stays as-is
    }
  }
}
