import 'package:ministryhub/ministryhub.dart';

/// Use case for watching a ministry for real-time updates
class WatchMinistryUseCase {
  const WatchMinistryUseCase(this._repository);

  final MinistryRepository _repository;

  Stream<Ministry?> call(String ministryId) {
    return _repository.watchMinistry(ministryId);
  }
}
