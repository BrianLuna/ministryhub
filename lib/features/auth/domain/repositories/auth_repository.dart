import 'package:ministryhub/ministryhub.dart';

abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  Future<AuthUser?> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser?> signInWithGoogle();

  Future<void> signOut();
}
