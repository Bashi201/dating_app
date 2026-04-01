import 'package:dio/dio.dart';

class SafetyService {
  final Dio _dio;
  SafetyService(this._dio);

  Future<void> blockUser(int userId) => _dio.post('/block/$userId');

  Future<void> unblockUser(int userId) => _dio.delete('/block/$userId');

  Future<void> reportUser(int userId, String reason, {String? description}) =>
      _dio.post(
        '/report/$userId',
        data: {
          'reason': reason,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );

  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    final res = await _dio.get('/blocks');
    return List<Map<String, dynamic>>.from(res.data['blocked_users']);
  }
}
