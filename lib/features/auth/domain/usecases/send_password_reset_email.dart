import 'package:ministryhub/ministryhub.dart';

class SendPasswordResetEmailUseCase {
  SendPasswordResetEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}
