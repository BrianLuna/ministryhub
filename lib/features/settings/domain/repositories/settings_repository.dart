import 'package:ministryhub/ministryhub.dart';

/// Repository interface for user settings operations
abstract class SettingsRepository {
  /// Update user profile (name, photo)
  Future<void> updateProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? profilePhotoPath,
  });

  /// Get user profile from Firestore
  Future<UserProfile?> getUserProfile(String uid);

  /// Delete user account and all associated data
  Future<void> deleteAccount(String uid);

  /// Upload profile photo to Storage
  Future<String> uploadProfilePhoto({
    required String uid,
    required List<int> imageData,
  });

  /// Delete profile photo from Storage
  Future<void> deleteProfilePhoto(String photoPath);
}
