import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ministryhub/ministryhub.dart';

/// Mock data source for RevenueCat operations
/// This mock bypasses RevenueCat and allows direct subscription updates
/// to Firestore without making actual purchases
///
/// IMPORTANT: This is a temporary mock implementation. When using this mock,
/// the subscription update flow should bypass RevenueCat verification and
/// update Firestore directly.
class MockRevenueCatDatasource implements RevenueCatDatasourceInterface {
  /// Configure mock (no-op)
  @override
  Future<void> configure(String apiKey) async {
    if (kDebugMode) {
      debugPrint('MockRevenueCat: configure called (no-op)');
    }
  }

  /// Set user ID for mock (no-op)
  @override
  Future<void> setUserId(String userId) async {
    if (kDebugMode) {
      debugPrint('MockRevenueCat: setUserId called (no-op)');
    }
  }

  /// Get mock offerings
  /// In mock mode, this will throw an exception indicating that
  /// offerings are not available. The UI should handle this gracefully.
  @override
  Future<Offerings> getOfferings() async {
    if (kDebugMode) {
      debugPrint(
        'MockRevenueCat: getOfferings called - throwing exception for mock mode',
      );
    }

    // In mock mode, we don't have real offerings
    // The UI should handle this by allowing direct subscription selection
    throw SubscriptionException(
      message:
          'Mock mode: Offerings not available. Use direct subscription update.',
    );
  }

  /// Purchase a package (mock)
  /// In mock mode, this throws a special exception that indicates
  /// the subscription should be updated directly in Firestore
  /// without RevenueCat verification
  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    if (kDebugMode) {
      debugPrint(
        'MockRevenueCat: purchasePackage called for package: ${package.identifier}',
      );
      debugPrint(
        'MockRevenueCat: This is a mock - subscription should be updated directly in Firestore',
      );
    }

    // In mock mode, throw a special exception that indicates
    // the subscription should be updated directly without RevenueCat
    throw SubscriptionException(message: 'MOCK_MODE_DIRECT_UPDATE');
  }

  /// Restore purchases (mock)
  @override
  Future<CustomerInfo> restorePurchases() async {
    if (kDebugMode) {
      debugPrint(
        'MockRevenueCat: restorePurchases called (not supported in mock mode)',
      );
    }

    throw SubscriptionException(message: 'Mock mode: Restore not available');
  }

  /// Get current customer info (mock)
  @override
  Future<CustomerInfo> getCustomerInfo() async {
    if (kDebugMode) {
      debugPrint(
        'MockRevenueCat: getCustomerInfo called (not supported in mock mode)',
      );
    }

    throw SubscriptionException(
      message: 'Mock mode: Customer info not available',
    );
  }
}
