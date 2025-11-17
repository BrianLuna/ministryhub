import 'package:firebase_auth/firebase_auth.dart';
import 'package:ministryhub/ministryhub.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final FirebaseAuthDatasource _datasource;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _datasource.authStateChanges().map(_mapUser);
  }

  @override
  Future<AuthUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _datasource.signInWithEmail(
        email: email,
        password: password,
      );
      return _mapUser(credential.user);
    } on AuthFailure {
      rethrow;
    } catch (error) {
      throw AuthFailure(
        code: AuthErrorCodes.generic,
        message: error.toString(),
        cause: error,
      );
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      final credential = await _datasource.signInWithGoogle();
      return _mapUser(credential.user);
    } on AuthFailure {
      rethrow;
    } catch (error) {
      throw AuthFailure(
        code: AuthErrorCodes.generic,
        message: error.toString(),
        cause: error,
      );
    }
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
