import '../repositories/church_repository.dart';

/// Use case for deleting a church
class DeleteChurchUseCase {
  const DeleteChurchUseCase(this._repository);

  final ChurchRepository _repository;

  Future<void> call(String ministryId, String churchId) async {
    return _repository.deleteChurch(ministryId, churchId);
  }
}
