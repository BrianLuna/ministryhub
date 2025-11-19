import 'package:ministryhub/ministryhub.dart';

/// Use case for watching ministries by user for real-time updates
class WatchMinistriesByUserUseCase {
  const WatchMinistriesByUserUseCase(this._repository);

  final MinistryRepository _repository;

  Stream<List<Ministry>> call(String userId) {
    return _repository.watchMinistriesByUser(userId);
  }
}
