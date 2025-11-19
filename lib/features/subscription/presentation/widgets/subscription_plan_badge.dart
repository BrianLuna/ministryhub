import 'package:flutter/material.dart';
import 'package:ministryhub/ministryhub.dart';

/// Badge showing the active subscription plan with gradient text
class SubscriptionPlanBadge extends StatelessWidget {
  const SubscriptionPlanBadge({super.key, required this.subscriptionType});

  final SubscriptionType subscriptionType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final planName = _getPlanName(subscriptionType, l10n);
    final gradient = _getGradientForType(subscriptionType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        planName,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  LinearGradient _getGradientForType(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.free:
        return const LinearGradient(
          colors: [
            Color(0xFF6B7280), // Gray
            Color(0xFF9CA3AF), // Light Gray
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SubscriptionType.pro:
        return const LinearGradient(
          colors: [
            Color(0xFF3B82F6), // Blue
            Color(0xFF8B5CF6), // Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SubscriptionType.premium:
        return const LinearGradient(
          colors: [
            Color(0xFFF59E0B), // Amber
            Color(0xFFEF4444), // Red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  String _getPlanName(SubscriptionType type, AppLocalizations l10n) {
    switch (type) {
      case SubscriptionType.free:
        return l10n.subscriptionFreeTitle.toUpperCase();
      case SubscriptionType.pro:
        return l10n.subscriptionProTitle.toUpperCase();
      case SubscriptionType.premium:
        return l10n.subscriptionPremiumTitle.toUpperCase();
    }
  }
}
