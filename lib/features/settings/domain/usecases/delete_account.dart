import 'package:ministryhub/ministryhub.dart';

/// Use case for deleting user account
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(String uid) async {
    return _repository.deleteAccount(uid);
  }
}
