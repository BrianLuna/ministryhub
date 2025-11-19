import 'package:purchases_flutter/purchases_flutter.dart';

/// Interface for RevenueCat datasource operations
/// Allows both real and mock implementations
abstract class RevenueCatDatasourceInterface {
  /// Configure RevenueCat with API key
  Future<void> configure(String apiKey);

  /// Set user ID for RevenueCat
  Future<void> setUserId(String userId);

  /// Get available offerings
  Future<Offerings> getOfferings();

  /// Purchase a package
  Future<CustomerInfo> purchasePackage(Package package);

  /// Restore purchases
  Future<CustomerInfo> restorePurchases();

  /// Get current customer info
  Future<CustomerInfo> getCustomerInfo();
}
