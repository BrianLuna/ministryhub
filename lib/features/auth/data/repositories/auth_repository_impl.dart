import 'package:firebase_auth/firebase_auth.dart';
import 'package:ministryhub/ministryhub.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final FirebaseAuthDatasource _datasource;
  final _firebaseAuth = FirebaseAuth.instance;

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
      // After reload in datasource, try to get the current user
      // which should have the updated photoURL after reload
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        // Use currentUser which should have the reloaded data including photoURL
        return _mapUser(currentUser);
      }
      // Fallback to credential user if currentUser is null
      final user = credential.user;
      if (user != null) {
        return _mapUser(user);
      }
      return null;
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

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _datasource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<AuthUser?> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential = await _datasource.registerWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
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
