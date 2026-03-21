import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ministryhub/ministryhub.dart';

/// Opens the paywall and updates the ministry subscription (RevenueCat + controller).
///
/// When [popOnSuccess] is true, pops the current route after a successful update
/// (e.g. closing a settings overlay).
Future<void> showMinistrySubscriptionChangeFlow(
  BuildContext context,
  WidgetRef ref,
  Ministry ministry, {
  bool popOnSuccess = false,
}) async {
  if (!context.mounted) return;

  final subscriptionState = ref.read(subscriptionControllerProvider);

  if (subscriptionState.offerings == null) {
    await ref.read(subscriptionControllerProvider.notifier).loadOfferings();
  }

  if (!context.mounted) return;

  final updatedState = ref.read(subscriptionControllerProvider);
  final offerings = updatedState.offerings;

  if (!context.mounted) return;

  await PaywallBottomSheet.show(
    context,
    ministryId: ministry.id,
    onSubscriptionSelected: (subscriptionType) async {
      if (!context.mounted) return;

      Package? package;
      if (subscriptionType != SubscriptionType.free &&
          offerings?.current != null) {
        package = _findPackageForSubscription(
          offerings!.current!,
          subscriptionType,
        );
      }

      final success = await ref
          .read(ministryControllerProvider.notifier)
          .updateSubscription(
            ministryId: ministry.id,
            subscriptionType: subscriptionType,
            package: package,
          );

      if (!context.mounted) return;

      final callbackL10n = AppLocalizations.of(context)!;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(callbackL10n.ministrySubscriptionUpdated)),
        );
        if (popOnSuccess) {
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(callbackL10n.ministrySubscriptionUpdateError),
          ),
        );
      }
    },
  );
}

Package? _findPackageForSubscription(
  Offering offering,
  SubscriptionType subscriptionType,
) {
  final entitlementId = subscriptionType == SubscriptionType.pro
      ? 'pro'
      : 'premium';

  for (final package in offering.availablePackages) {
    if (package.storeProduct.identifier.contains('monthly') ||
        package.packageType == PackageType.monthly) {
      if (package.storeProduct.identifier.toLowerCase().contains(
            entitlementId.toLowerCase(),
          )) {
        return package;
      }
    }
  }
  for (final package in offering.availablePackages) {
    if (package.storeProduct.identifier.contains('yearly') ||
        package.packageType == PackageType.annual) {
      if (package.storeProduct.identifier.toLowerCase().contains(
            entitlementId.toLowerCase(),
          )) {
        return package;
      }
    }
  }
  return offering.availablePackages.isNotEmpty
      ? offering.availablePackages.first
      : null;
}
