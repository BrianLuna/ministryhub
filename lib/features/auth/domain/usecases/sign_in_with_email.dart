import 'package:ministryhub/ministryhub.dart';

class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser?> call({required String email, required String password}) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
