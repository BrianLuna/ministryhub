import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Provider that returns the currently selected religious entity (church or ministry)
/// Priority: church > ministry
/// This provides a unified, polymorphic way to access the selected entity
final selectedReligiousEntityProvider = Provider<ReligiousEntity?>((ref) {
  final churchState = ref.watch(churchControllerProvider);
  final ministryState = ref.watch(ministryControllerProvider);

  // Priority: church > ministry
  if (churchState.selectedChurch != null) {
    return churchState.selectedChurch;
  }
  return ministryState.selectedMinistry;
});

/// Provider that returns the subscription type of the currently selected entity
/// For churches, it returns the subscription of the church's ministry
/// For ministries, it returns the ministry's subscription directly
final currentSubscriptionTypeProvider = Provider<SubscriptionType?>((ref) {
  final selectedEntity = ref.watch(selectedReligiousEntityProvider);
  final ministryState = ref.watch(ministryControllerProvider);

  if (selectedEntity == null) return null;

  if (selectedEntity is Ministry) {
    return selectedEntity.subscriptionType;
  }

  if (selectedEntity is Church) {
    // Find the ministry of the church in the ministries list
    try {
      final ministry = ministryState.ministries.firstWhere(
        (m) => m.id == selectedEntity.ministryId,
      );
      return ministry.subscriptionType;
    } catch (e) {
      // Ministry not found in list, try selectedMinistry as fallback
      // This can happen if the ministry was just loaded but not yet in the list
      if (ministryState.selectedMinistry?.id == selectedEntity.ministryId) {
        return ministryState.selectedMinistry?.subscriptionType;
      }
      return null;
    }
  }

  return null;
});

/// Ministry whose subscription is reflected in [currentSubscriptionTypeProvider]
/// (direct selection or parent of the selected church).
final currentSubscriptionMinistryProvider = Provider<Ministry?>((ref) {
  final selectedEntity = ref.watch(selectedReligiousEntityProvider);
  final ministryState = ref.watch(ministryControllerProvider);

  if (selectedEntity == null) return null;

  if (selectedEntity is Ministry) {
    return selectedEntity;
  }

  if (selectedEntity is Church) {
    try {
      return ministryState.ministries.firstWhere(
        (m) => m.id == selectedEntity.ministryId,
      );
    } catch (_) {
      if (ministryState.selectedMinistry?.id == selectedEntity.ministryId) {
        return ministryState.selectedMinistry;
      }
      return null;
    }
  }

  return null;
});
