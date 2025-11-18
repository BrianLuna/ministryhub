import 'package:ministryhub/ministryhub.dart';

class WatchAuthStateUseCase {
  const WatchAuthStateUseCase(this._repository);

  final AuthRepository _repository;

  Stream<AuthUser?> call() => _repository.authStateChanges();
}
