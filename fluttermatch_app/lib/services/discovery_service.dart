import 'package:dio/dio.dart';
import '../models/discover_user_model.dart';

class DiscoveryService {
  final Dio _dio;
  DiscoveryService(this._dio);

  Future<List<DiscoverUserModel>> getDiscoverFeed() async {
    final res = await _dio.get('/discover');
    final list = res.data['users'] as List<dynamic>;
    return list
        .map((u) => DiscoverUserModel.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  /// Returns {matched: bool, match_id: int?}
  Future<Map<String, dynamic>> likeUser(int userId) async {
    final res = await _dio.post('/like/$userId');
    return {
      'matched': res.data['matched'] ?? false,
      'match_id': res.data['match_id'],
    };
  }

  Future<void> dislikeUser(int userId) => _dio.post('/dislike/$userId');
}
