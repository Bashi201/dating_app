import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/match_model.dart';
import '../models/message_model.dart';
import '../services/match_service.dart';

final matchServiceProvider = Provider<MatchService>((ref) {
  return MatchService(ref.watch(dioProvider));
});

final matchProvider =
    StateNotifierProvider<MatchNotifier, AsyncValue<List<MatchModel>>>(
      (ref) => MatchNotifier(ref.watch(matchServiceProvider)),
    );

class MatchNotifier extends StateNotifier<AsyncValue<List<MatchModel>>> {
  final MatchService _service;

  MatchNotifier(this._service) : super(const AsyncValue.loading()) {
    loadMatches();
  }

  Future<void> loadMatches() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getMatches());
  }

  void updateLastMessage(int matchId, MessageModel message) {
    final matches = state.valueOrNull ?? [];
    state = AsyncValue.data(
      matches.map((m) {
        if (m.id != matchId) return m;
        return m.copyWith(
          lastMessage: LastMessage(
            body: message.body,
            isMine: message.isMine,
            createdAt: message.createdAt,
          ),
          unreadCount: message.isMine ? 0 : m.unreadCount + 1,
        );
      }).toList(),
    );
  }

  void clearUnread(int matchId) {
    final matches = state.valueOrNull ?? [];
    state = AsyncValue.data(
      matches
          .map((m) => m.id == matchId ? m.copyWith(unreadCount: 0) : m)
          .toList(),
    );
  }

  int totalUnread() {
    return (state.valueOrNull ?? []).fold(0, (sum, m) => sum + m.unreadCount);
  }
}
