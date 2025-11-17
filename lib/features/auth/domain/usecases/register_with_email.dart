import 'package:ministryhub/ministryhub.dart';

class RegisterWithEmailUseCase {
  RegisterWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser?> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return _repository.registerWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
