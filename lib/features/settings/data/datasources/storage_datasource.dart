import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:ministryhub/ministryhub.dart';

/// Data source for Firebase Storage operations related to user photos
class StorageDatasource {
  StorageDatasource({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Upload profile photo to Storage
  Future<String> uploadProfilePhoto({
    required String uid,
    required List<int> imageData,
  }) async {
    try {
      final ref = _storage.ref().child('users/$uid/profile.jpg');
      await ref.putData(
        Uint8List.fromList(imageData),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      throw SettingsException(
        message: 'Failed to upload profile photo: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Delete profile photo from Storage
  /// [photoPath] can be either a Storage path (e.g., "users/uid/profile.jpg")
  /// or a download URL
  Future<void> deleteProfilePhoto(String photoPath) async {
    try {
      Reference ref;
      if (photoPath.startsWith('http')) {
        // It's a download URL, try to get reference from URL
        try {
          ref = _storage.refFromURL(photoPath);
        } catch (e) {
          // If refFromURL fails, try to extract path from URL
          final uri = Uri.parse(photoPath);
          final pathSegments = uri.pathSegments;
          final pathIndex = pathSegments.indexOf('users');
          if (pathIndex != -1) {
            final path = pathSegments.sublist(pathIndex).join('/');
            ref = _storage.ref().child(path);
          } else {
            // If we can't extract path, try default path
            // Extract uid from URL if possible
            final uidMatch = RegExp(r'/users/([^/]+)/').firstMatch(photoPath);
            if (uidMatch != null) {
              final uid = uidMatch.group(1);
              ref = _storage.ref().child('users/$uid/profile.jpg');
            } else {
              throw SettingsException(
                message: 'Could not determine photo path from URL',
              );
            }
          }
        }
      } else {
        // It's a direct path
        ref = _storage.ref().child(photoPath);
      }
      await ref.delete();
    } catch (e) {
      // Don't throw if file doesn't exist
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      if (e is SettingsException) {
        rethrow;
      }
      throw SettingsException(
        message: 'Failed to delete profile photo: ${e.toString()}',
        cause: e,
      );
    }
  }
}
