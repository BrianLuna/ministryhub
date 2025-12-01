import '../repositories/church_repository.dart';
import '../entities/location.dart';

/// Use case for updating church information
class UpdateChurchUseCase {
  const UpdateChurchUseCase(this._repository);

  final ChurchRepository _repository;

  Future<void> call({
    required String ministryId,
    required String churchId,
    String? name,
    Location? location,
    String? newMinistryId,
  }) async {
    return _repository.updateChurch(
      ministryId: ministryId,
      churchId: churchId,
      name: name,
      location: location,
      newMinistryId: newMinistryId,
    );
  }
}
