import '../repositories/church_repository.dart';
import '../entities/church.dart';

/// Use case for getting all churches for a specific ministry
class GetChurchesByMinistryUseCase {
  const GetChurchesByMinistryUseCase(this._repository);

  final ChurchRepository _repository;

  Future<List<Church>> call(String ministryId) async {
    return _repository.getChurchesByMinistry(ministryId);
  }
}
