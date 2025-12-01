import '../repositories/church_repository.dart';
import '../entities/church.dart';

/// Use case for watching a single church for real-time updates
class WatchChurchUseCase {
  const WatchChurchUseCase(this._repository);

  final ChurchRepository _repository;

  Stream<Church?> call(String ministryId, String churchId) {
    return _repository.watchChurch(ministryId, churchId);
  }
}
