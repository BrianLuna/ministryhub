import '../repositories/church_repository.dart';
import '../entities/church.dart';

/// Use case for watching all churches for a specific ministry
class WatchChurchesByMinistryUseCase {
  const WatchChurchesByMinistryUseCase(this._repository);

  final ChurchRepository _repository;

  Stream<List<Church>> call(String ministryId) {
    return _repository.watchChurchesByMinistry(ministryId);
  }
}
