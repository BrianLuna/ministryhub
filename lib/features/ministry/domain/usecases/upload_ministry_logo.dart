import 'package:ministryhub/ministryhub.dart';

/// Use case for uploading ministry logo
class UploadMinistryLogoUseCase {
  const UploadMinistryLogoUseCase(this._repository);

  final MinistryRepository _repository;

  Future<String> call({
    required String ministryId,
    required List<int> imageData,
  }) async {
    return _repository.uploadMinistryLogo(
      ministryId: ministryId,
      imageData: imageData,
    );
  }
}
