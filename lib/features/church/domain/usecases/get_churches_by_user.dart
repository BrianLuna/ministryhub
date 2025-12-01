import '../repositories/church_repository.dart';
import '../entities/church.dart';

/// Use case for getting all churches accessible by a user
class GetChurchesByUserUseCase {
  const GetChurchesByUserUseCase(this._repository);

  final ChurchRepository _repository;

  Future<List<Church>> call(String userId) async {
    return _repository.getChurchesByUser(userId);
  }
}
