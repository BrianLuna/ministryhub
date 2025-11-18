import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Provider for theme preferences service
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

/// Provider for current user's theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.user?.uid;
  final preferencesService = ref.watch(preferencesServiceProvider);

  return ThemeModeNotifier(
    preferencesService: preferencesService,
    userId: userId,
  );
});

/// Notifier for managing theme mode preferences
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier({
    required PreferencesService preferencesService,
    String? userId,
  }) : _preferencesService = preferencesService,
       _userId = userId,
       super(ThemeMode.system) {
    _loadThemeMode();
  }

  final PreferencesService _preferencesService;
  String? _userId;

  /// Load theme mode from preferences or use system default
  Future<void> _loadThemeMode() async {
    if (_userId == null) {
      state = ThemeMode.system;
      return;
    }

    try {
      final themeString = await _preferencesService.getStringForUser(
        'theme',
        _userId!,
      );
      if (themeString == null) {
        state = ThemeMode.system;
        return;
      }

      switch (themeString) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        case 'system':
        default:
          state = ThemeMode.system;
          break;
      }
    } catch (e) {
      // If there's an error loading preferences, use system default
      state = ThemeMode.system;
    }
  }

  /// Set theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_userId == null) return;

    state = themeMode;
    final themeString = themeMode == ThemeMode.light
        ? 'light'
        : themeMode == ThemeMode.dark
        ? 'dark'
        : 'system';
    await _preferencesService.setStringForUser('theme', _userId!, themeString);
  }

  /// Update user ID when user changes
  void updateUserId(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _loadThemeMode();
  }
}
