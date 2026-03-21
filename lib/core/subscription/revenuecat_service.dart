import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ministryhub/ministryhub.dart';

/// Service for initializing RevenueCat
class RevenueCatService {
  const RevenueCatService._();

  static bool _isInitialized = false;

  /// Check if RevenueCat is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize RevenueCat with API key from environment
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Hot restart / web: native SDK may still be configured while Dart statics reset.
      if (await Purchases.isConfigured) {
        _isInitialized = true;
        if (kDebugMode) {
          debugPrint(
            'RevenueCat SDK already configured; skipping Purchases.configure().',
          );
        }
        return;
      }

      // `main()` usually loads `.env` first; avoid reloading (and duplicate logs).
      if (!dotenv.isInitialized) {
        try {
          await dotenv.load(fileName: '.env');
          if (kDebugMode) {
            debugPrint('Successfully loaded .env file (RevenueCat)');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              'Warning: Could not load .env file: $e. RevenueCat will not be initialized.',
            );
          }
          return;
        }
      }

      // Now safe to access dotenv.env after loading
      final apiKey = dotenv.env['REVENUECAT_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'Warning: REVENUECAT_API_KEY not found in environment variables. RevenueCat will not be initialized.',
          );
        }
        return;
      }

      if (kDebugMode) {
        debugPrint('Configuring RevenueCat with API key...');
      }

      final datasource = RevenueCatDatasource();
      await datasource.configure(apiKey);
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('RevenueCat initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing RevenueCat: $e');
        debugPrint('Error type: ${e.runtimeType}');
        if (e is Error) {
          debugPrint('Stack trace: ${e.stackTrace}');
        }
      }
      // Don't throw - allow app to continue without RevenueCat
      // This is important for development when .env might not be set up
    }
  }

  /// Set user ID for RevenueCat
  static Future<void> setUserId(String userId) async {
    try {
      final datasource = RevenueCatDatasource();
      await datasource.setUserId(userId);
    } catch (e) {
      if (e is SubscriptionException) {
        rethrow;
      }
      throw SubscriptionException(
        message: 'Failed to set RevenueCat user ID: ${e.toString()}',
        cause: e,
      );
    }
  }
}
