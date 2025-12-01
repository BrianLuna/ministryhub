import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:ministryhub/core/platform/google_maps_config.dart';

/// Loader responsible for injecting the Google Maps JS SDK on web builds
class GoogleMapsLoader {
  const GoogleMapsLoader._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Ensure the Google Maps script has been injected for web builds
  static Future<void> ensureInitialized() async {
    if (_isInitialized) {
      return;
    }

    final apiKey = GoogleMapsConfig.webKey;
    if (apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'Google Maps web key is missing. '
          'Set GOOGLE_MAPS_WEB_DEV_KEY/GOOGLE_MAPS_WEB_PROD_KEY in .env',
        );
      }
      return;
    }

    // Avoid injecting the script twice
    final existingScript = web.document.querySelector(
      'script[data-mh-google-maps="true"]',
    );
    if (existingScript != null) {
      _isInitialized = true;
      return;
    }

    final script = web.HTMLScriptElement()
      ..type = 'text/javascript'
      ..src =
          'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places'
      ..setAttribute('data-mh-google-maps', 'true');

    web.document.head?.append(script);

    _isInitialized = true;
  }
}
