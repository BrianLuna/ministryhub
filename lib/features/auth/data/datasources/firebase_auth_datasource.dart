import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
      UserCredential credential;
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        credential = await _firebaseAuth.signInWithPopup(provider);
        // In web, wait for reload to ensure photoURL is available
        try {
          await credential.user?.reload();
          // After reload, the currentUser should have the updated photoURL
          // The repository will use currentUser if available
        } catch (e) {
          // If reload fails, continue anyway - user is already authenticated
        }
      } else {
        final googleSignIn = _googleSignIn;
        if (googleSignIn == null) {
          throw const AuthFailure(code: AuthErrorCodes.generic);
        }
        final googleUser = await googleSignIn.signIn().timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const AuthFailure(
              code: AuthErrorCodes.generic,
              message: 'Google Sign-In timed out',
            );
          },
        );
        if (googleUser == null) {
          throw const AuthFailure(code: AuthErrorCodes.googleCancelled);
        }
        GoogleSignInAuthentication googleAuth;
        try {
          googleAuth = await googleUser.authentication.timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw const AuthFailure(
                code: AuthErrorCodes.generic,
                message: 'Failed to get authentication tokens',
              );
            },
          );
        } catch (e) {
          // If authentication fails, it might be a network or configuration issue
          throw AuthFailure(
            code: AuthErrorCodes.generic,
            message: 'Failed to get Google authentication: ${e.toString()}',
            cause: e,
          );
        }
        if (googleAuth.accessToken == null || googleAuth.idToken == null) {
          throw const AuthFailure(
            code: AuthErrorCodes.generic,
            message: 'Google authentication tokens are null',
          );
        }
        credential = await _firebaseAuth
            .signInWithCredential(
              GoogleAuthProvider.credential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
              ),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw const AuthFailure(
                  code: AuthErrorCodes.generic,
                  message: 'Firebase sign-in timed out',
                );
              },
            );
        // On mobile, reload asynchronously to avoid blocking
        credential.user?.reload().catchError((_) {
          // Silently ignore reload errors - user is already authenticated
        });
      }
      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(
        code: _mapFirebaseCode(error.code),
        message: error.message,
        cause: error,
      );
    } on PlatformException catch (error) {
      // Handle Google Sign-In platform-specific errors
      final errorCode = error.code;
      if (errorCode == 'sign_in_canceled' || errorCode == 'sign_in_cancelled') {
        throw const AuthFailure(code: AuthErrorCodes.googleCancelled);
      }
      throw AuthFailure(
        code: AuthErrorCodes.generic,
        message: error.message ?? error.toString(),
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

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
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

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final displayName = '$firstName $lastName'.trim();
      if (displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
        await credential.user?.reload();
      }
      return credential;
    } on FirebaseAuthException catch (error) {
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
      case 'invalid-credential':
        return AuthErrorCodes.wrongPassword;
      case 'user-disabled':
        return AuthErrorCodes.userDisabled;
      case 'user-not-found':
        return AuthErrorCodes.userNotFound;
      case 'account-exists-with-different-credential':
      case 'credential-already-in-use':
        return AuthErrorCodes.credentialConflict;
      default:
        return AuthErrorCodes.generic;
    }
  }
}
