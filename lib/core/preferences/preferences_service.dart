import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user-specific preferences in SharedPreferences
class PreferencesService {
  PreferencesService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  Future<void> init() async {
    if (_prefs != null) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // If SharedPreferences is not available (e.g., plugin not registered),
      // we'll continue with null and use default values
      // This can happen in web if the plugin isn't properly initialized
    }
  }

  /// Get a string value for a specific user
  Future<String?> getStringForUser(String key, String userId) async {
    try {
      await init();
      if (_prefs == null) return null;
      final userKey = '${key}_$userId';
      return _prefs!.getString(userKey);
    } catch (e) {
      // If there's an error, return null to use default values
      return null;
    }
  }

  /// Set a string value for a specific user
  Future<bool> setStringForUser(String key, String userId, String value) async {
    try {
      await init();
      if (_prefs == null) return false;
      final userKey = '${key}_$userId';
      return await _prefs!.setString(userKey, value);
    } catch (e) {
      // If there's an error, return false
      // This can happen if the plugin isn't available
      return false;
    }
  }

  /// Remove all preferences for a specific user
  Future<void> clearUserPreferences(String userId) async {
    try {
      await init();
      if (_prefs == null) return;

      final keys = _prefs!.getKeys();
      final userKeys = keys.where((key) => key.endsWith('_$userId'));
      for (final key in userKeys) {
        await _prefs!.remove(key);
      }
    } catch (e) {
      // Silently fail if preferences can't be cleared
      // This can happen if the plugin isn't available (e.g., during testing)
    }
  }

  /// Get SharedPreferences instance (for direct access if needed)
  SharedPreferences? get prefs => _prefs;
}
