import 'package:ministryhub/ministryhub.dart';

/// Use case for creating a new church
class CreateChurchUseCase {
  const CreateChurchUseCase(this._churchRepository, this._ministryRepository);

  final ChurchRepository _churchRepository;
  final MinistryRepository _ministryRepository;

  Future<Church> call({
    required String name,
    required Location location,
    required String ministryId,
  }) async {
    // Get ministry to check subscription limits
    final ministry = await _ministryRepository.getMinistry(ministryId);
    if (ministry == null) {
      throw ChurchException(message: 'Ministry not found');
    }

    // Check current church count
    final currentCount = await _churchRepository.getChurchesCountByMinistry(
      ministryId,
    );

    // Get subscription limits
    final maxChurches = SubscriptionLimits.getMaxChurches(
      ministry.subscriptionType,
    );

    // Validate limit (if maxChurches is -1, it's unlimited)
    if (maxChurches != -1 && currentCount >= maxChurches) {
      throw ChurchException(
        message:
            'Church limit reached for ${ministry.subscriptionType.name} subscription',
      );
    }

    return _churchRepository.createChurch(
      name: name,
      location: location,
      ministryId: ministryId,
    );
  }
}
