import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ministryhub/ministryhub.dart';

/// Implementation of SubscriptionRepository
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required RevenueCatDatasource revenueCatDatasource,
  }) : _revenueCatDatasource = revenueCatDatasource;

  final RevenueCatDatasource _revenueCatDatasource;

  @override
  Future<Offerings> getOfferings() async {
    try {
      return await _revenueCatDatasource.getOfferings();
    } catch (e) {
      if (e is SubscriptionException) {
        rethrow;
      }
      throw SubscriptionException(
        message: 'Failed to get offerings: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      return await _revenueCatDatasource.purchasePackage(package);
    } catch (e) {
      if (e is SubscriptionException) {
        rethrow;
      }
      throw SubscriptionException(
        message: 'Failed to purchase package: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    try {
      return await _revenueCatDatasource.restorePurchases();
    } catch (e) {
      if (e is SubscriptionException) {
        rethrow;
      }
      throw SubscriptionException(
        message: 'Failed to restore purchases: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await _revenueCatDatasource.getCustomerInfo();
    } catch (e) {
      if (e is SubscriptionException) {
        rethrow;
      }
      throw SubscriptionException(
        message: 'Failed to get customer info: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  bool hasActiveEntitlement(CustomerInfo customerInfo, String entitlementId) {
    try {
      final entitlement = customerInfo.entitlements.all[entitlementId];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      return false;
    }
  }

  @override
  SubscriptionType? getActiveSubscriptionType(CustomerInfo customerInfo) {
    try {
      // Check for premium entitlement first
      if (hasActiveEntitlement(customerInfo, 'premium')) {
        return SubscriptionType.premium;
      }
      // Check for pro entitlement
      if (hasActiveEntitlement(customerInfo, 'pro')) {
        return SubscriptionType.pro;
      }
      // No active subscription, return null (will default to free)
      return null;
    } catch (e) {
      return null;
    }
  }
}
