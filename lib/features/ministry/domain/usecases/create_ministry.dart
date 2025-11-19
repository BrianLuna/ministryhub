import 'package:ministryhub/ministryhub.dart';

/// Use case for creating a new ministry
class CreateMinistryUseCase {
  const CreateMinistryUseCase(this._repository);

  final MinistryRepository _repository;

  Future<Ministry> call({
    required String name,
    required String administratorId,
  }) async {
    return _repository.createMinistry(
      name: name,
      administratorId: administratorId,
    );
  }
}
