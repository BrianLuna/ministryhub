import '../repositories/church_repository.dart';
import '../entities/church.dart';

/// Use case for watching all churches accessible by a user
class WatchChurchesByUserUseCase {
  const WatchChurchesByUserUseCase(this._repository);

  final ChurchRepository _repository;

  Stream<List<Church>> call(String userId) {
    return _repository.watchChurchesByUser(userId);
  }
}
