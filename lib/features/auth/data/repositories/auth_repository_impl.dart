import 'package:firebase_auth/firebase_auth.dart';
import 'package:ministryhub/ministryhub.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._datasource, {
    FirestoreDatasource? firestoreDatasource,
  }) : _firestoreDatasource = firestoreDatasource ?? FirestoreDatasource();

  final FirebaseAuthDatasource _datasource;
  final FirestoreDatasource _firestoreDatasource;
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
      final user = credential.user;
      if (user != null) {
        // Ensure email is up to date in Firestore (but don't overwrite existing profile data)
        try {
          final existingProfile = await _firestoreDatasource.getUserProfile(
            user.uid,
          );

          // Only update email if it's different or if profile doesn't exist
          if (existingProfile == null || existingProfile['email'] != email) {
            await _firestoreDatasource.saveUserProfile(
              uid: user.uid,
              data: {'email': email},
            );
          }
        } catch (e) {
          // Log but don't fail sign-in if Firestore update fails
          // User is already authenticated
        }
      }
      return _mapUser(user);
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
      final user = currentUser ?? credential.user;
      if (user != null) {
        // Save or update user profile in Firestore
        try {
          // Check if profile already exists
          final existingProfile = await _firestoreDatasource.getUserProfile(
            user.uid,
          );

          // Only save if profile doesn't exist or if email/displayName changed
          // But never overwrite existing firstName/lastName
          final needsUpdate =
              existingProfile == null ||
              existingProfile['email'] != user.email ||
              (user.displayName != null &&
                  existingProfile['displayName'] != user.displayName);

          if (needsUpdate) {
            final profileData = <String, dynamic>{'email': user.email};

            // Add displayName if available
            if (user.displayName != null && user.displayName!.isNotEmpty) {
              profileData['displayName'] = user.displayName;
            }

            // Only extract firstName/lastName from displayName if profile doesn't exist
            // Never overwrite existing firstName/lastName (they won't be in profileData if existingProfile != null)
            if (existingProfile == null && user.displayName != null) {
              final nameParts = user.displayName!
                  .trim()
                  .split(' ')
                  .where((p) => p.isNotEmpty)
                  .toList();
              if (nameParts.isNotEmpty) {
                profileData['firstName'] = nameParts.first;
                if (nameParts.length > 1) {
                  profileData['lastName'] = nameParts.skip(1).join(' ');
                }
              }
            }
            // If existingProfile != null, we don't add firstName/lastName to profileData
            // This ensures we never overwrite existing firstName/lastName when using merge: true

            await _firestoreDatasource.saveUserProfile(
              uid: user.uid,
              data: profileData,
            );
          }
        } catch (e) {
          // Log but don't fail sign-in if Firestore save fails
          // User is already authenticated
        }

        // Use currentUser which should have the reloaded data including photoURL
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
      final user = credential.user;
      if (user != null) {
        // Save user profile to Firestore
        try {
          await _firestoreDatasource.saveUserProfile(
            uid: user.uid,
            data: {
              'firstName': firstName,
              'lastName': lastName,
              'email': email,
            },
          );
        } catch (e) {
          // Log but don't fail registration if Firestore save fails
          // User is already created in Firebase Auth
        }
      }
      return _mapUser(user);
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
    // Get the primary provider ID from providerData
    final providerId = user.providerData.isNotEmpty
        ? user.providerData[0].providerId
        : 'password';
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      providerId: providerId,
    );
  }
}
