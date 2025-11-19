import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ministryhub/ministryhub.dart';

/// Data source for Firestore operations related to ministries
class MinistryFirestoreDatasource {
  MinistryFirestoreDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Create a new ministry in Firestore
  Future<String> createMinistry({
    required String name,
    required String administratorId,
  }) async {
    try {
      final docRef = _firestore.collection('ministries').doc();
      final now = DateTime.now();
      await docRef.set({
        'name': name,
        'createdAt': Timestamp.fromDate(now),
        'administratorId': administratorId,
      });
      return docRef.id;
    } catch (e) {
      throw MinistryException(
        message: 'Failed to create ministry: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Get all ministries where the user is administrator
  Future<List<Map<String, dynamic>>> getMinistriesByAdministrator(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('ministries')
          .where('administratorId', isEqualTo: userId)
          .get();

      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();

      // Sort by createdAt descending in memory
      // Note: For better performance, create a Firestore composite index:
      // Collection: ministries, Fields: administratorId (Ascending), createdAt (Descending)
      results.sort((a, b) {
        final aCreatedAt = a['createdAt'] as Timestamp?;
        final bCreatedAt = b['createdAt'] as Timestamp?;
        if (aCreatedAt == null && bCreatedAt == null) return 0;
        if (aCreatedAt == null) return 1;
        if (bCreatedAt == null) return -1;
        return bCreatedAt.compareTo(aCreatedAt);
      });

      return results;
    } catch (e) {
      throw MinistryException(
        message: 'Failed to get ministries: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Get all ministries where the user is administrator or member
  /// For now, only returns ministries where user is administrator
  /// Future: will also query members subcollection
  Future<List<Map<String, dynamic>>> getMinistriesByUser(String userId) async {
    // For now, same as getMinistriesByAdministrator
    // Future: will also query ministries where user is in members subcollection
    return getMinistriesByAdministrator(userId);
  }

  /// Watch all ministries where the user is administrator for real-time updates
  Stream<List<Map<String, dynamic>>> watchMinistriesByAdministrator(
    String userId,
  ) {
    try {
      return _firestore
          .collection('ministries')
          .where('administratorId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            final results = snapshot.docs.map((doc) {
              final data = doc.data();
              return {'id': doc.id, ...data};
            }).toList();

            // Sort by createdAt descending in memory
            results.sort((a, b) {
              final aCreatedAt = a['createdAt'] as Timestamp?;
              final bCreatedAt = b['createdAt'] as Timestamp?;
              if (aCreatedAt == null && bCreatedAt == null) return 0;
              if (aCreatedAt == null) return 1;
              if (bCreatedAt == null) return -1;
              return bCreatedAt.compareTo(aCreatedAt);
            });

            return results;
          })
          .handleError((error) {
            throw MinistryException(
              message: 'Failed to watch ministries: ${error.toString()}',
              cause: error,
            );
          });
    } catch (e) {
      throw MinistryException(
        message: 'Failed to watch ministries: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Watch all ministries where the user is administrator or member
  /// For now, only returns ministries where user is administrator
  /// Future: will also query members subcollection
  Stream<List<Map<String, dynamic>>> watchMinistriesByUser(String userId) {
    // For now, same as watchMinistriesByAdministrator
    // Future: will also query ministries where user is in members subcollection
    return watchMinistriesByAdministrator(userId);
  }

  /// Get a single ministry by ID
  Future<Map<String, dynamic>?> getMinistry(String ministryId) async {
    try {
      final doc = await _firestore
          .collection('ministries')
          .doc(ministryId)
          .get();
      if (!doc.exists) {
        return null;
      }
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw MinistryException(
        message: 'Failed to get ministry: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Watch a single ministry by ID for real-time updates
  Stream<Map<String, dynamic>?> watchMinistry(String ministryId) {
    try {
      return _firestore
          .collection('ministries')
          .doc(ministryId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              return null;
            }
            return {'id': snapshot.id, ...snapshot.data()!};
          })
          .handleError((error) {
            throw MinistryException(
              message: 'Failed to watch ministry: ${error.toString()}',
              cause: error,
            );
          });
    } catch (e) {
      throw MinistryException(
        message: 'Failed to watch ministry: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Update ministry name
  Future<void> updateMinistry({
    required String ministryId,
    required String name,
  }) async {
    try {
      await _firestore.collection('ministries').doc(ministryId).update({
        'name': name,
      });
    } catch (e) {
      throw MinistryException(
        message: 'Failed to update ministry: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Update ministry logo URL
  Future<void> updateMinistryLogoUrl({
    required String ministryId,
    required String logoUrl,
  }) async {
    try {
      await _firestore.collection('ministries').doc(ministryId).update({
        'logoUrl': logoUrl,
      });
    } catch (e) {
      throw MinistryException(
        message: 'Failed to update ministry logo URL: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Delete ministry from Firestore
  Future<void> deleteMinistry(String ministryId) async {
    try {
      await _firestore.collection('ministries').doc(ministryId).delete();
    } catch (e) {
      throw MinistryException(
        message: 'Failed to delete ministry: ${e.toString()}',
        cause: e,
      );
    }
  }
}
