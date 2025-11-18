import 'package:ministryhub/ministryhub.dart';

/// Use case for updating user profile
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call({
    required String uid,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? profilePhotoPath,
  }) async {
    return _repository.updateProfile(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      photoUrl: photoUrl,
      profilePhotoPath: profilePhotoPath,
    );
  }
}
