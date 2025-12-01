import '../repositories/church_repository.dart';

/// Use case for getting the count of churches for a ministry
class GetChurchesCountByMinistryUseCase {
  const GetChurchesCountByMinistryUseCase(this._repository);

  final ChurchRepository _repository;

  Future<int> call(String ministryId) async {
    return _repository.getChurchesCountByMinistry(ministryId);
  }
}
