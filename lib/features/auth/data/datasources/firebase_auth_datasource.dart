import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ministryhub/ministryhub.dart';

class FirebaseAuthDatasource {
  FirebaseAuthDatasource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? _buildGoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        return _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      throw AuthFailure(
        code: _mapFirebaseCode(error.code),
        message: error.message,
        cause: error,
      );
    } catch (error) {
      throw AuthFailure(
        code: AuthErrorCodes.generic,
        message: error.toString(),
        cause: error,
      );
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        return _firebaseAuth.signInWithPopup(provider);
      }

      final googleSignIn = _googleSignIn;
      if (googleSignIn == null) {
        throw const AuthFailure(code: AuthErrorCodes.generic);
      }
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure(code: AuthErrorCodes.googleCancelled);
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(
        code: _mapFirebaseCode(error.code),
        message: error.message,
        cause: error,
      );
    } catch (error) {
      if (error is AuthFailure) {
        rethrow;
      }
      throw AuthFailure(
        code: AuthErrorCodes.generic,
        message: error.toString(),
        cause: error,
      );
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await _googleSignIn?.signOut();
    }
  }

  static GoogleSignIn? _buildGoogleSignIn() {
    if (kIsWeb) {
      final clientId = GoogleClientIdResolver.resolve();
      return GoogleSignIn(clientId: clientId);
    }
    return GoogleSignIn();
  }

  String _mapFirebaseCode(String code) {
    switch (code) {
      case 'invalid-email':
        return AuthErrorCodes.invalidEmail;
      case 'wrong-password':
        return AuthErrorCodes.wrongPassword;
      case 'user-disabled':
        return AuthErrorCodes.userDisabled;
      case 'account-exists-with-different-credential':
      case 'credential-already-in-use':
        return AuthErrorCodes.credentialConflict;
      default:
        return AuthErrorCodes.generic;
    }
  }
}
