import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Google Maps with environment-specific API key
    // These keys should be set in your build configuration
    // For dev builds, use GOOGLE_MAPS_IOS_DEV_KEY
    // For prod builds, use GOOGLE_MAPS_IOS_PROD_KEY
    #if DEBUG
    // Development environment
    if let apiKey = Bundle.main.infoDictionary?["GOOGLE_MAPS_IOS_DEV_KEY"] as? String {
      GMSServices.provideAPIKey(apiKey)
    }
    #else
    // Production environment
    if let apiKey = Bundle.main.infoDictionary?["GOOGLE_MAPS_IOS_PROD_KEY"] as? String {
      GMSServices.provideAPIKey(apiKey)
    }
    #endif
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
