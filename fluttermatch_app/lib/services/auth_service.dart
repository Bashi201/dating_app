import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthResponse {
  final String token;
  final UserModel user;
  const AuthResponse({required this.token, required this.user});
}

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  // ─── Register ───────────────────────────────────────
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data['data'];
      return AuthResponse(
        token: data['token'],
        user: UserModel.fromJson(data['user']),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Login ──────────────────────────────────────────
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      return AuthResponse(
        token: data['token'],
        user: UserModel.fromJson(data['user']),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Logout ─────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
      // Even if API fails, clear local token
    } finally {
      await SecureStorage.deleteToken();
    }
  }

  // ─── Get Current User ────────────────────────────────
  Future<UserModel> getMe() async {
    final response = await _dio.get('/me');
    return UserModel.fromJson(response.data['data']);
  }
  // ─── Forgot password ────────────────────────────────

  Future<void> forgotPassword({required String email}) async {
    await _dio.post(ApiConstants.forgotPass, data: {'email': email});
  }

  // ─── Error Handler ───────────────────────────────────
  String _handleError(DioException e) {
    if (e.response?.data != null) {
      // Laravel validation errors
      final errors = e.response?.data['errors'];
      if (errors != null && errors is Map) {
        return errors.values.first[0]; // return first validation message
      }
      return e.response?.data['message'] ?? 'Something went wrong.';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Check your internet.';
    }
    return 'Network error. Please try again.';
  }
  // ── In AuthService (auth_service.dart) — add new method ──────────────────────

  Future<void> resendVerification(String email) async {
    await _dio.post('/email/resend', data: {'email': email});
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dio.post(
      ApiConstants.resetPass, // '/reset-password'
      data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
}
