import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ministryhub/ministryhub.dart';

/// Repository interface for subscription operations
abstract class SubscriptionRepository {
  /// Get available offerings from RevenueCat
  Future<Offerings> getOfferings();

  /// Purchase a package
  Future<CustomerInfo> purchasePackage(Package package);

  /// Restore purchases
  Future<CustomerInfo> restorePurchases();

  /// Get current customer info
  Future<CustomerInfo> getCustomerInfo();

  /// Check if user has active entitlement
  bool hasActiveEntitlement(CustomerInfo customerInfo, String entitlementId);

  /// Get active subscription type from customer info
  SubscriptionType? getActiveSubscriptionType(CustomerInfo customerInfo);
}
