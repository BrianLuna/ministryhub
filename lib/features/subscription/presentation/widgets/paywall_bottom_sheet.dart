import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ministryhub/ministryhub.dart';

/// Modern bottom sheet paywall for subscription selection
class PaywallBottomSheet extends ConsumerStatefulWidget {
  const PaywallBottomSheet({
    super.key,
    required this.ministryId,
    required this.onSubscriptionSelected,
  });

  final String ministryId;
  final ValueChanged<SubscriptionType> onSubscriptionSelected;

  /// Show the paywall bottom sheet
  static Future<SubscriptionType?> show(
    BuildContext context, {
    required String ministryId,
    required ValueChanged<SubscriptionType> onSubscriptionSelected,
  }) async {
    return showModalBottomSheet<SubscriptionType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallBottomSheet(
        ministryId: ministryId,
        onSubscriptionSelected: onSubscriptionSelected,
      ),
    );
  }

  @override
  ConsumerState<PaywallBottomSheet> createState() => _PaywallBottomSheetState();
}

class _PaywallBottomSheetState extends ConsumerState<PaywallBottomSheet> {
  Package? _selectedPackage;
  SubscriptionType? _selectedSubscriptionType;
  bool _isProcessingPurchase = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionControllerProvider.notifier).loadOfferings();
    });
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null || _selectedSubscriptionType == null) {
      return;
    }

    // Prevent multiple simultaneous purchases
    if (_isProcessingPurchase) {
      return;
    }

    final subscriptionState = ref.read(subscriptionControllerProvider);
    if (subscriptionState.isPurchasing) {
      return;
    }

    setState(() {
      _isProcessingPurchase = true;
    });

    try {
      final controller = ref.read(subscriptionControllerProvider.notifier);
      final customerInfo = await controller.purchasePackage(_selectedPackage!);

      if (customerInfo != null && mounted) {
        // Verify the subscription was successful
        final repository = ref.read(subscriptionRepositoryProvider);
        final subscriptionType = repository.getActiveSubscriptionType(
          customerInfo,
        );

        if (subscriptionType != null) {
          widget.onSubscriptionSelected(subscriptionType);
          Navigator.of(context).pop(subscriptionType);
          return;
        }
      } else if (mounted) {
        // Show error
        final state = ref.read(subscriptionControllerProvider);
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPurchase = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final offerings = subscriptionState.offerings;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(77),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  l10n.subscriptionPaywallTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.subscriptionPaywallSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: subscriptionState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : offerings?.current == null
                ? Center(
                    child: Text(
                      l10n.subscriptionNoOfferings,
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : _buildSubscriptionOptions(context, offerings!.current!),
          ),
          // Bottom actions
          if (!subscriptionState.isLoading && offerings?.current != null)
            _buildBottomActions(context, subscriptionState),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOptions(BuildContext context, Offering offering) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Free tier
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _SubscriptionOptionCard(
              title: l10n.subscriptionFreeTitle,
              description: l10n.subscriptionFreeDescription,
              features: [
                l10n.subscriptionFreeFeature1,
                l10n.subscriptionFreeFeature2,
              ],
              isSelected: _selectedSubscriptionType == SubscriptionType.free,
              onTap: () {
                setState(() {
                  _selectedSubscriptionType = SubscriptionType.free;
                  _selectedPackage = null;
                });
              },
              price: '\$0.00',
            ),
          ),
          const SizedBox(height: 16),
          // Pro tier
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _SubscriptionOptionCard(
              title: l10n.subscriptionProTitle,
              description: l10n.subscriptionProDescription,
              features: [
                l10n.subscriptionProFeature1,
                l10n.subscriptionProFeature2,
              ],
              isSelected: _selectedSubscriptionType == SubscriptionType.pro,
              onTap: () {
                setState(() {
                  _selectedSubscriptionType = SubscriptionType.pro;
                  _selectedPackage = _findPackageForSubscriptionType(
                    offering,
                    SubscriptionType.pro,
                  );
                });
              },
              price: _getPackagePrice(offering, SubscriptionType.pro),
              isPopular: true,
            ),
          ),
          const SizedBox(height: 16),
          // Premium tier
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _SubscriptionOptionCard(
              title: l10n.subscriptionPremiumTitle,
              description: l10n.subscriptionPremiumDescription,
              features: [
                l10n.subscriptionPremiumFeature1,
                l10n.subscriptionPremiumFeature2,
              ],
              isSelected: _selectedSubscriptionType == SubscriptionType.premium,
              onTap: () {
                setState(() {
                  _selectedSubscriptionType = SubscriptionType.premium;
                  _selectedPackage = _findPackageForSubscriptionType(
                    offering,
                    SubscriptionType.premium,
                  );
                });
              },
              price: _getPackagePrice(offering, SubscriptionType.premium),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Package? _findPackageForSubscriptionType(
    Offering offering,
    SubscriptionType subscriptionType,
  ) {
    switch (subscriptionType) {
      case SubscriptionType.free:
        return null;
      case SubscriptionType.pro:
        return offering.monthly ??
            _findPackageByPackageType(offering, PackageType.monthly) ??
            _findPackageByIdentifier(offering, 'monthly') ??
            _fallbackPackage(offering);
      case SubscriptionType.premium:
        return offering.annual ??
            _findPackageByPackageType(offering, PackageType.annual) ??
            _findPackageByIdentifier(offering, 'annual') ??
            _findPackageByIdentifier(offering, 'yearly') ??
            _fallbackPackage(offering);
    }
  }

  Package? _findPackageByPackageType(Offering offering, PackageType type) {
    for (final package in offering.availablePackages) {
      if (package.packageType == type) {
        return package;
      }
    }
    return null;
  }

  Package? _findPackageByIdentifier(Offering offering, String identifier) {
    final target = identifier.toLowerCase();
    for (final package in offering.availablePackages) {
      final identifiers = <String>[
        package.identifier.toLowerCase(),
        package.storeProduct.identifier.toLowerCase(),
      ];
      if (identifiers.any((value) => value.contains(target))) {
        return package;
      }
    }
    return null;
  }

  Package? _fallbackPackage(Offering offering) {
    if (offering.availablePackages.isEmpty) {
      return null;
    }
    // Prefer the first available package as a safe fallback
    return offering.availablePackages.first;
  }

  String _getPackagePrice(
    Offering offering,
    SubscriptionType subscriptionType,
  ) {
    final package = _findPackageForSubscriptionType(offering, subscriptionType);
    if (package != null) {
      return package.storeProduct.priceString;
    }
    return '';
  }

  Widget _buildBottomActions(BuildContext context, SubscriptionState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withAlpha(77),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  state.isPurchasing ||
                      _isProcessingPurchase ||
                      _selectedSubscriptionType == null ||
                      (_selectedSubscriptionType != SubscriptionType.free &&
                          _selectedPackage == null)
                  ? null
                  : _selectedSubscriptionType == SubscriptionType.free
                  ? () {
                      widget.onSubscriptionSelected(SubscriptionType.free);
                      Navigator.of(context).pop(SubscriptionType.free);
                    }
                  : _handlePurchase,
              child: state.isPurchasing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _selectedSubscriptionType == SubscriptionType.free
                          ? l10n.subscriptionContinueFree
                          : l10n.subscriptionSubscribe,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.subscriptionMaybeLater),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionOptionCard extends StatefulWidget {
  const _SubscriptionOptionCard({
    required this.title,
    required this.description,
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.price,
    this.isPopular = false,
  });

  final String title;
  final String description;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;
  final String price;
  final bool isPopular;

  @override
  State<_SubscriptionOptionCard> createState() =>
      _SubscriptionOptionCardState();
}

class _SubscriptionOptionCardState extends State<_SubscriptionOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: widget.isSelected
                  ? null
                  : Border.all(
                      color: theme.colorScheme.outline.withAlpha(77),
                      width: 1,
                    ),
            ),
            child: Stack(
              children: [
                // Animated gradient border
                if (widget.isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: SweepGradient(
                          center: Alignment.center,
                          startAngle: _animation.value * 2 * 3.14159,
                          endAngle: (_animation.value * 2 * 3.14159) + 3.14159,
                          colors: [
                            const Color(0xFF3B82F6), // Blue
                            const Color(0xFF8B5CF6), // Purple
                            const Color(0xFFEC4899), // Pink
                            const Color(0xFF3B82F6), // Blue
                          ],
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (widget.isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'POPULAR',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (widget.price.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.price,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        widget.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
