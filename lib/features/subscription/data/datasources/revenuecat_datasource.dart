import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ministryhub/ministryhub.dart';

/// Data source for RevenueCat operations
class RevenueCatDatasource {
  /// Configure RevenueCat with API key
  Future<void> configure(String apiKey) async {
    try {
      // Configure RevenueCat first
      await Purchases.configure(PurchasesConfiguration(apiKey));

      // Set log level after configuration
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
    } catch (e) {
      throw SubscriptionException(
        message: 'Failed to configure RevenueCat: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Set user ID for RevenueCat
  Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      throw SubscriptionException(
        message: 'Failed to set user ID: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Get available offerings
  Future<Offerings> getOfferings() async {
    try {
      // Check if RevenueCat is configured
      if (!RevenueCatService.isInitialized) {
        throw SubscriptionException(
          message:
              'RevenueCat is not initialized. Please check your .env file.',
        );
      }

      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) {
        throw SubscriptionException(message: 'No current offering available');
      }
      return offerings;
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

  /// Purchase a package
  Future<CustomerInfo> purchasePackage(Package package) async {
    if (!RevenueCatService.isInitialized) {
      throw SubscriptionException(
        message: 'RevenueCat is not initialized. Please check your .env file.',
      );
    }

    try {
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      return purchaseResult.customerInfo;
    } on PurchasesError catch (e) {
      // Check if purchase was cancelled
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        throw SubscriptionException(message: 'Purchase was cancelled');
      }
      throw SubscriptionException(
        message: 'Purchase failed: ${e.message}',
        cause: e,
      );
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

  /// Restore purchases
  Future<CustomerInfo> restorePurchases() async {
    if (!RevenueCatService.isInitialized) {
      throw SubscriptionException(
        message: 'RevenueCat is not initialized. Please check your .env file.',
      );
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
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

  /// Get current customer info
  Future<CustomerInfo> getCustomerInfo() async {
    if (!RevenueCatService.isInitialized) {
      throw SubscriptionException(
        message: 'RevenueCat is not initialized. Please check your .env file.',
      );
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
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
}
