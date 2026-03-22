import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/discover_user_model.dart';
import '../services/discovery_service.dart';

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  return DiscoveryService(ref.watch(dioProvider));
});

// Holds the card stack
final discoveryProvider =
    StateNotifierProvider<
      DiscoveryNotifier,
      AsyncValue<List<DiscoverUserModel>>
    >((ref) => DiscoveryNotifier(ref.watch(discoveryServiceProvider)));

// Holds match result after a like
final matchResultProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class DiscoveryNotifier
    extends StateNotifier<AsyncValue<List<DiscoverUserModel>>> {
  final DiscoveryService _service;

  DiscoveryNotifier(this._service) : super(const AsyncValue.loading()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getDiscoverFeed());
  }

  void removeTop() {
    final current = state.valueOrNull ?? [];
    if (current.isEmpty) return;
    final next = current.sublist(1);
    state = AsyncValue.data(next);
  }

  Future<Map<String, dynamic>> likeTop() async {
    final current = state.valueOrNull ?? [];
    if (current.isEmpty) return {'matched': false};
    final userId = current.first.id;
    removeTop();
    
    // Wait for the backend to process the like and invalidate the cache
    final result = await _service.likeUser(userId);
    
    // Refill when running low, AFTER like is recorded
    if ((state.valueOrNull ?? []).length < 3) {
      loadFeed();
    }
    
    return result;
  }

  Future<void> dislikeTop() async {
    final current = state.valueOrNull ?? [];
    if (current.isEmpty) return;
    final userId = current.first.id;
    removeTop();
    
    await _service.dislikeUser(userId);
    
    if ((state.valueOrNull ?? []).length < 3) {
      loadFeed();
    }
  }
}
