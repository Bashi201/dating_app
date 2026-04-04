import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kDarkModeKey = 'is_dark_mode';
const _storage = FlutterSecureStorage();

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    try {
      final val = await _storage.read(key: _kDarkModeKey);
      if (val == 'true') state = ThemeMode.dark;
    } catch (_) {}
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    try {
      await _storage.write(
        key: _kDarkModeKey,
        value: next == ThemeMode.dark ? 'true' : 'false',
      );
    } catch (_) {}
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
