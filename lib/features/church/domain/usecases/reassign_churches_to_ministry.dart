import '../repositories/church_repository.dart';

/// Use case for reassigning churches from one ministry to another
class ReassignChurchesToMinistryUseCase {
  const ReassignChurchesToMinistryUseCase(this._repository);

  final ChurchRepository _repository;

  Future<void> call({
    required String fromMinistryId,
    required String toMinistryId,
  }) async {
    return _repository.reassignChurchesToMinistry(
      fromMinistryId: fromMinistryId,
      toMinistryId: toMinistryId,
    );
  }
}
