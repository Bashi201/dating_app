import 'package:dio/dio.dart';
import '../models/match_model.dart';
import '../models/message_model.dart';

class MatchService {
  final Dio _dio;
  MatchService(this._dio);

  Future<List<MatchModel>> getMatches() async {
    final res = await _dio.get('/matches');
    return (res.data['matches'] as List)
        .map((m) => MatchModel.fromJson(m))
        .toList();
  }

  Future<List<MessageModel>> getMessages(int matchId) async {
    final res = await _dio.get('/matches/$matchId/messages');
    return (res.data['messages'] as List)
        .map((m) => MessageModel.fromJson(m))
        .toList();
  }

  Future<MessageModel> sendMessage(int matchId, String body) async {
    final res = await _dio.post(
      '/matches/$matchId/messages',
      data: {'body': body},
    );
    return MessageModel.fromJson(res.data['message']);
  }

  Future<void> markRead(int matchId) => _dio.post('/matches/$matchId/read');
}
