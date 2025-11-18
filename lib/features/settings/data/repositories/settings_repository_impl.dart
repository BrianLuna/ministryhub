import 'package:firebase_auth/firebase_auth.dart';
import 'package:ministryhub/ministryhub.dart';

/// Implementation of SettingsRepository
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required FirestoreDatasource firestoreDatasource,
    required StorageDatasource storageDatasource,
    FirebaseAuth? firebaseAuth,
  }) : _firestoreDatasource = firestoreDatasource,
       _storageDatasource = storageDatasource,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirestoreDatasource _firestoreDatasource;
  final StorageDatasource _storageDatasource;
  final FirebaseAuth _firebaseAuth;

  @override
  Future<void> updateProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? profilePhotoPath,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const SettingsException(message: 'User not authenticated');
      }

      // Get current profile from Firestore to preserve existing values
      final currentProfile = await getUserProfile(uid);
      final currentFirstName = firstName ?? currentProfile?.firstName;
      final currentLastName = lastName ?? currentProfile?.lastName;

      // If no profile exists and we have displayName from Auth, use it
      if (currentProfile == null && user.displayName != null) {
        final nameParts = user.displayName!.split(' ');
        if (currentFirstName == null && nameParts.isNotEmpty) {
          // Will be set below
        }
        if (currentLastName == null && nameParts.length > 1) {
          // Will be set below
        }
      }

      // Update display name in Firebase Auth if name changed
      if (firstName != null || lastName != null) {
        // Use current values if new ones are not provided
        final finalFirstName = firstName ?? currentFirstName ?? '';
        final finalLastName = lastName ?? currentLastName ?? '';
        final displayName = _buildDisplayName(finalFirstName, finalLastName);
        if (displayName != null && displayName != user.displayName) {
          await user.updateDisplayName(displayName);
          await user.reload();
        }
      }

      // Update photo URL in Firebase Auth if photo changed
      if (photoUrl != null && photoUrl != user.photoURL) {
        await user.updatePhotoURL(photoUrl);
        await user.reload();
      }

      // Save profile data to Firestore
      // Only include fields that are explicitly provided (not null)
      // This preserves existing values in Firestore
      final profileData = <String, dynamic>{};
      if (firstName != null) {
        profileData['firstName'] = firstName;
      }
      if (lastName != null) {
        profileData['lastName'] = lastName;
      }
      if (photoUrl != null) {
        profileData['photoUrl'] = photoUrl;
      }
      if (profilePhotoPath != null) {
        profileData['profilePhotoPath'] = profilePhotoPath;
      }

      if (profileData.isNotEmpty) {
        await _firestoreDatasource.saveUserProfile(uid: uid, data: profileData);
      }
    } catch (e) {
      if (e is SettingsException) {
        rethrow;
      }
      throw SettingsException(
        message: 'Failed to update profile: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final data = await _firestoreDatasource.getUserProfile(uid);
      if (data == null) {
        return null;
      }
      return UserProfile(
        uid: uid,
        firstName: data['firstName'] as String?,
        lastName: data['lastName'] as String?,
        email: data['email'] as String?,
        photoUrl: data['photoUrl'] as String?,
        profilePhotoPath: data['profilePhotoPath'] as String?,
      );
    } catch (e) {
      if (e is SettingsException) {
        rethrow;
      }
      throw SettingsException(
        message: 'Failed to get user profile: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteAccount(String uid) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.uid != uid) {
        throw const SettingsException(message: 'User not authenticated');
      }

      // Get profile to check for photo path
      final profile = await getUserProfile(uid);

      // Delete profile photo from Storage if exists
      if (profile?.profilePhotoPath != null) {
        try {
          await _storageDatasource.deleteProfilePhoto(
            profile!.profilePhotoPath!,
          );
        } catch (e) {
          // Log but don't fail if photo deletion fails
          // Continue with account deletion
        }
      } else {
        // Try to delete using default path if profile doesn't exist
        try {
          await _storageDatasource.deleteProfilePhoto('users/$uid/profile.jpg');
        } catch (e) {
          // Ignore if file doesn't exist
        }
      }

      // Delete user data from Firestore
      try {
        await _firestoreDatasource.deleteUserProfile(uid);
      } catch (e) {
        // Log but continue with account deletion
      }

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      if (e is SettingsException) {
        rethrow;
      }
      throw SettingsException(
        message: 'Failed to delete account: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<String> uploadProfilePhoto({
    required String uid,
    required List<int> imageData,
  }) async {
    try {
      // Upload photo and get download URL
      final downloadUrl = await _storageDatasource.uploadProfilePhoto(
        uid: uid,
        imageData: imageData,
      );

      // Save the path (not the URL) to Firestore for easier deletion
      final photoPath = 'users/$uid/profile.jpg';
      await _firestoreDatasource.saveUserProfile(
        uid: uid,
        data: {'profilePhotoPath': photoPath},
      );

      return downloadUrl;
    } catch (e) {
      if (e is SettingsException) {
        rethrow;
      }
      throw SettingsException(
        message: 'Failed to upload profile photo: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteProfilePhoto(String photoPath) async {
    try {
      await _storageDatasource.deleteProfilePhoto(photoPath);
    } catch (e) {
      if (e is SettingsException) {
        rethrow;
      }
      throw SettingsException(
        message: 'Failed to delete profile photo: ${e.toString()}',
        cause: e,
      );
    }
  }

  String? _buildDisplayName(String? firstName, String? lastName) {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    if (firstName != null) return firstName;
    if (lastName != null) return lastName;
    return null;
  }
}
