import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ministryhub/ministryhub.dart';

/// Data source for Firestore operations related to user settings
class FirestoreDatasource {
  FirestoreDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Get user profile document from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return null;
      }
      return doc.data();
    } catch (e) {
      throw SettingsException(
        message: 'Failed to get user profile: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Save user profile to Firestore
  Future<void> saveUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw SettingsException(
        message: 'Failed to save user profile: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Delete user document from Firestore
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw SettingsException(
        message: 'Failed to delete user profile: ${e.toString()}',
        cause: e,
      );
    }
  }
}
