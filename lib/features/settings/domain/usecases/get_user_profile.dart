import 'package:ministryhub/ministryhub.dart';

/// Use case for getting user profile
class GetUserProfileUseCase {
  const GetUserProfileUseCase(this._repository);

  final SettingsRepository _repository;

  Future<UserProfile?> call(String uid) async {
    return _repository.getUserProfile(uid);
  }
}
