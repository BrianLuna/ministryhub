import 'package:ministryhub/ministryhub.dart';

/// Use case for getting all ministries where user is administrator
class GetMinistriesByAdministratorUseCase {
  const GetMinistriesByAdministratorUseCase(this._repository);

  final MinistryRepository _repository;

  Future<List<Ministry>> call(String userId) async {
    return _repository.getMinistriesByAdministrator(userId);
  }
}
