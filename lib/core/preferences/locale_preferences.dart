import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Provider for current user's locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.user?.uid;
  final preferencesService = ref.watch(preferencesServiceProvider);

  return LocaleNotifier(preferencesService: preferencesService, userId: userId);
});

/// Notifier for managing locale preferences
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier({
    required PreferencesService preferencesService,
    String? userId,
  }) : _preferencesService = preferencesService,
       _userId = userId,
       super(null) {
    _loadLocale();
  }

  final PreferencesService _preferencesService;
  String? _userId;

  /// Load locale from preferences or use null (system default)
  Future<void> _loadLocale() async {
    if (_userId == null) {
      state = null;
      return;
    }

    try {
      final localeString = await _preferencesService.getStringForUser(
        'locale',
        _userId!,
      );
      if (localeString == null) {
        state = null;
        return;
      }

      state = Locale(localeString);
    } catch (e) {
      // If there's an error loading preferences, use system default
      state = null;
    }
  }

  /// Set locale and save to preferences
  Future<void> setLocale(Locale? locale) async {
    if (_userId == null) return;

    state = locale;
    if (locale != null) {
      await _preferencesService.setStringForUser(
        'locale',
        _userId!,
        locale.languageCode,
      );
    } else {
      // Remove preference to use system default
      final userKey = 'locale_$_userId';
      await _preferencesService.prefs?.remove(userKey);
    }
  }

  /// Update user ID when user changes
  void updateUserId(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _loadLocale();
  }
}
