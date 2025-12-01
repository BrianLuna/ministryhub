/// No-op Google Maps loader for non-web platforms
class GoogleMapsLoader {
  const GoogleMapsLoader._();

  /// Google Maps is always considered initialized on non-web targets
  static bool get isInitialized => true;

  /// Nothing to do outside the web
  static Future<void> ensureInitialized() async {}
}
