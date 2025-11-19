import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ministryhub/ministryhub.dart';

/// Provider for subscription repository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final datasource = RevenueCatDatasource();
  return SubscriptionRepositoryImpl(revenueCatDatasource: datasource);
});

/// State for subscription operations
class SubscriptionState {
  const SubscriptionState({
    this.offerings,
    this.isLoading = false,
    this.isPurchasing = false,
    this.error,
  });

  final Offerings? offerings;
  final bool isLoading;
  final bool isPurchasing;
  final String? error;

  SubscriptionState copyWith({
    Offerings? offerings,
    bool? isLoading,
    bool? isPurchasing,
    String? error,
  }) {
    return SubscriptionState(
      offerings: offerings ?? this.offerings,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      error: error,
    );
  }
}

/// Controller for subscription operations
class SubscriptionController extends StateNotifier<SubscriptionState> {
  SubscriptionController({required SubscriptionRepository repository})
    : _repository = repository,
      super(const SubscriptionState());

  final SubscriptionRepository _repository;

  /// Load offerings
  Future<void> loadOfferings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final offerings = await _repository.getOfferings();
      state = state.copyWith(offerings: offerings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is SubscriptionException
            ? e.message ?? 'Failed to load offerings'
            : 'Failed to load offerings',
      );
    }
  }

  /// Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    state = state.copyWith(isPurchasing: true, error: null);
    try {
      final customerInfo = await _repository.purchasePackage(package);
      state = state.copyWith(isPurchasing: false);
      return customerInfo;
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        error: e is SubscriptionException
            ? e.message ?? 'Failed to purchase package'
            : 'Failed to purchase package',
      );
      return null;
    }
  }

  /// Restore purchases
  Future<CustomerInfo?> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final customerInfo = await _repository.restorePurchases();
      state = state.copyWith(isLoading: false);
      return customerInfo;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is SubscriptionException
            ? e.message ?? 'Failed to restore purchases'
            : 'Failed to restore purchases',
      );
      return null;
    }
  }
}

/// Provider for subscription controller
final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionState>((ref) {
      final repository = ref.watch(subscriptionRepositoryProvider);
      return SubscriptionController(repository: repository);
    });
