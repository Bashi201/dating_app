import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/photo_model.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(dioProvider)); // fixed: was dioClientProvider
});

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>((ref) {
      return ProfileNotifier(ref.watch(profileServiceProvider));
    });

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel?>> {
  final ProfileService _service;

  ProfileNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getProfile());
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final profile = await _service.updateProfile(data);
      state = AsyncValue.data(profile);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> uploadPhoto(String filePath) async {
    try {
      final photo = await _service.uploadPhoto(filePath);
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(
          current.copyWith(photos: [...current.photos, photo]),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePhoto(int photoId) async {
    try {
      await _service.deletePhoto(photoId);
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(
          current.copyWith(
            photos: current.photos.where((p) => p.id != photoId).toList(),
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setPrimaryPhoto(int photoId) async {
    try {
      await _service.setPrimaryPhoto(photoId);
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(
          current.copyWith(
            photos: current.photos
                .map((p) => p.copyWith(isPrimary: p.id == photoId))
                .toList(),
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
