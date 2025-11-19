import 'package:ministryhub/ministryhub.dart';

/// Use case for getting all ministries where user is admin or member
class GetMinistriesByUserUseCase {
  const GetMinistriesByUserUseCase(this._repository);

  final MinistryRepository _repository;

  Future<List<Ministry>> call(String userId) async {
    return _repository.getMinistriesByUser(userId);
  }
}
