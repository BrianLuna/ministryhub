import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

/// Configuration service for Google Maps API keys
/// Uses platform-specific keys for dev and prod environments
class GoogleMapsConfig {
  GoogleMapsConfig._();

  /// Get Google Maps API key for the current platform and environment
  /// Returns empty string if not configured
  static String get apiKey {
    try {
      final isDev = kDebugMode;

      // Get platform-specific key
      String? key;
      if (kIsWeb) {
        // Web platform
        key = isDev
            ? dotenv.env['GOOGLE_MAPS_WEB_DEV_KEY']
            : dotenv.env['GOOGLE_MAPS_WEB_PROD_KEY'];
      } else if (Platform.isAndroid) {
        // Android platform
        key = isDev
            ? dotenv.env['GOOGLE_MAPS_ANDROID_DEV_KEY']
            : dotenv.env['GOOGLE_MAPS_ANDROID_PROD_KEY'];
      } else if (Platform.isIOS) {
        // iOS platform
        key = isDev
            ? dotenv.env['GOOGLE_MAPS_IOS_DEV_KEY']
            : dotenv.env['GOOGLE_MAPS_IOS_PROD_KEY'];
      }

      return key ?? '';
    } catch (e) {
      // dotenv not loaded or key not found
      return '';
    }
  }

  /// Get Android API key for the current environment
  static String get androidKey {
    try {
      final isDev = kDebugMode;
      final key = isDev
          ? dotenv.env['GOOGLE_MAPS_ANDROID_DEV_KEY']
          : dotenv.env['GOOGLE_MAPS_ANDROID_PROD_KEY'];
      return key ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Get iOS API key for the current environment
  static String get iosKey {
    try {
      final isDev = kDebugMode;
      final key = isDev
          ? dotenv.env['GOOGLE_MAPS_IOS_DEV_KEY']
          : dotenv.env['GOOGLE_MAPS_IOS_PROD_KEY'];
      return key ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Get Web API key for the current environment
  static String get webKey {
    try {
      final isDev = kDebugMode;
      final key = isDev
          ? dotenv.env['GOOGLE_MAPS_WEB_DEV_KEY']
          : dotenv.env['GOOGLE_MAPS_WEB_PROD_KEY'];
      return key ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Check if Google Maps is properly configured
  static bool get isConfigured {
    return apiKey.isNotEmpty;
  }

  /// Get current environment name for debugging
  static String get currentEnvironment {
    return kDebugMode ? 'dev' : 'prod';
  }
}
