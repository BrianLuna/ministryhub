import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:ministryhub/ministryhub.dart';

/// Data source for Firebase Storage operations related to ministry logos
class MinistryStorageDatasource {
  MinistryStorageDatasource({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Upload ministry logo to Storage
  Future<String> uploadMinistryLogo({
    required String ministryId,
    required List<int> imageData,
  }) async {
    try {
      final ref = _storage.ref().child('ministries/$ministryId/logo.jpg');
      await ref.putData(
        Uint8List.fromList(imageData),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      throw MinistryException(
        message: 'Failed to upload ministry logo: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Delete ministry logo from Storage
  /// [logoPath] can be either a Storage path (e.g., "ministries/ministryId/logo.jpg")
  /// or a download URL
  Future<void> deleteMinistryLogo(String logoPath) async {
    try {
      Reference ref;
      if (logoPath.startsWith('http')) {
        // It's a download URL, try to get reference from URL
        try {
          ref = _storage.refFromURL(logoPath);
        } catch (e) {
          // If refFromURL fails, try to extract path from URL
          final uri = Uri.parse(logoPath);
          final pathSegments = uri.pathSegments;
          final pathIndex = pathSegments.indexOf('ministries');
          if (pathIndex != -1) {
            final path = pathSegments.sublist(pathIndex).join('/');
            ref = _storage.ref().child(path);
          } else {
            // If we can't extract path, try default path
            // Extract ministryId from URL if possible
            final ministryIdMatch = RegExp(
              r'/ministries/([^/]+)/',
            ).firstMatch(logoPath);
            if (ministryIdMatch != null) {
              final ministryId = ministryIdMatch.group(1);
              ref = _storage.ref().child('ministries/$ministryId/logo.jpg');
            } else {
              throw MinistryException(
                message: 'Could not determine logo path from URL',
              );
            }
          }
        }
      } else {
        // It's a direct path
        ref = _storage.ref().child(logoPath);
      }
      await ref.delete();
    } catch (e) {
      // Don't throw if file doesn't exist
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to delete ministry logo: ${e.toString()}',
        cause: e,
      );
    }
  }
}
