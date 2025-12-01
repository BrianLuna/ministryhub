import 'package:ministryhub/ministryhub.dart';

/// Use case for deleting a ministry
class DeleteMinistryUseCase {
  const DeleteMinistryUseCase(this._ministryRepository, this._churchRepository);

  final MinistryRepository _ministryRepository;
  final ChurchRepository _churchRepository;

  Future<void> call({
    required String ministryId,
    MinistryDeletionStrategy? strategy,
    String? targetMinistryId,
  }) async {
    // Check if ministry has churches
    final churchCount = await _churchRepository.getChurchesCountByMinistry(
      ministryId,
    );

    if (churchCount > 0) {
      if (strategy == null) {
        throw MinistryException(
          message: 'Ministry has churches. Strategy required.',
        );
      }

      if (strategy == MinistryDeletionStrategy.reassignChurches) {
        if (targetMinistryId == null) {
          throw MinistryException(
            message: 'Target ministry ID required for reassignment',
          );
        }
        // Reassign churches to target ministry
        await _churchRepository.reassignChurchesToMinistry(
          fromMinistryId: ministryId,
          toMinistryId: targetMinistryId,
        );
      }
      // If strategy is deleteChurches, churches will be deleted
      // as part of the subcollection deletion when ministry is deleted
    }

    // Delete ministry (this will also delete churches if they're subcollections)
    return _ministryRepository.deleteMinistry(ministryId);
  }
}
