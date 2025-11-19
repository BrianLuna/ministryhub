import 'package:ministryhub/ministryhub.dart';

/// Use case for updating ministry subscription type
class UpdateMinistrySubscriptionUseCase {
  const UpdateMinistrySubscriptionUseCase(this._repository);

  final MinistryRepository _repository;

  Future<void> call({
    required String ministryId,
    required SubscriptionType subscriptionType,
  }) async {
    return _repository.updateMinistrySubscriptionType(
      ministryId: ministryId,
      subscriptionType: subscriptionType,
    );
  }
}
