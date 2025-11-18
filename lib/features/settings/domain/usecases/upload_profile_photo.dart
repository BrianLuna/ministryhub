import 'package:ministryhub/ministryhub.dart';

/// Use case for uploading profile photo
class UploadProfilePhotoUseCase {
  const UploadProfilePhotoUseCase(this._repository);

  final SettingsRepository _repository;

  Future<String> call({
    required String uid,
    required List<int> imageData,
  }) async {
    return _repository.uploadProfilePhoto(uid: uid, imageData: imageData);
  }
}
