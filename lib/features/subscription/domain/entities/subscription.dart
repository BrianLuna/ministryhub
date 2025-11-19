import 'package:equatable/equatable.dart';
import 'package:ministryhub/ministryhub.dart';

/// Domain entity representing a subscription
class Subscription extends Equatable {
  const Subscription({
    required this.type,
    this.productId,
    this.entitlementId,
    this.expiresDate,
    this.isActive = false,
  });

  final SubscriptionType type;
  final String? productId;
  final String? entitlementId;
  final DateTime? expiresDate;
  final bool isActive;

  @override
  List<Object?> get props => [
        type,
        productId,
        entitlementId,
        expiresDate,
        isActive,
      ];
}

