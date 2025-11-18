import 'package:flutter/foundation.dart';

import 'google_client_id_strategy.dart'
    if (dart.library.html) 'google_client_id_strategy_web.dart';

/// Resolves the Google Sign-In client id for the current platform.
class GoogleClientIdResolver {
  const GoogleClientIdResolver._();

  static final GoogleClientIdStrategy _strategy = GoogleClientIdStrategy();

  /// Returns the client id for the current build mode when available.
  static String? resolve() {
    final isProd = kReleaseMode;
    return _strategy.resolve(isProd: isProd);
  }
}
