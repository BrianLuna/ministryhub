import 'package:ministryhub/ministryhub.dart';

/// Use case for checking if user is administrator of any ministry
class CheckUserIsAdministratorUseCase {
  const CheckUserIsAdministratorUseCase(this._repository);

  final MinistryRepository _repository;

  Future<bool> call(String userId) async {
    final ministries = await _repository.getMinistriesByAdministrator(userId);
    return ministries.isNotEmpty;
  }
}
