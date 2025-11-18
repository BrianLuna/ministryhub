import 'package:ministryhub/ministryhub.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser?> call() {
    return _repository.signInWithGoogle();
  }
}
