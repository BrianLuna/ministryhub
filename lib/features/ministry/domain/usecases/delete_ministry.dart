import 'package:ministryhub/ministryhub.dart';

/// Use case for deleting a ministry
class DeleteMinistryUseCase {
  const DeleteMinistryUseCase(this._repository);

  final MinistryRepository _repository;

  Future<void> call(String ministryId) async {
    return _repository.deleteMinistry(ministryId);
  }
}
