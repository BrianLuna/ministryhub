import 'package:ministryhub/ministryhub.dart';

/// Use case for updating ministry name
class UpdateMinistryUseCase {
  const UpdateMinistryUseCase(this._repository);

  final MinistryRepository _repository;

  Future<void> call({required String ministryId, required String name}) async {
    return _repository.updateMinistry(ministryId: ministryId, name: name);
  }
}
