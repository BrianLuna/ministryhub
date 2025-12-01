import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ministryhub/ministryhub.dart';

/// Data source for Firestore operations related to churches
/// Churches are stored as subcollections: ministries/{ministryId}/churches/{churchId}
class ChurchFirestoreDatasource {
  ChurchFirestoreDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Create a new church in Firestore
  Future<String> createChurch({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? placeId,
    required String ministryId,
  }) async {
    try {
      final churchesRef = _firestore
          .collection('ministries')
          .doc(ministryId)
          .collection('churches');
      final docRef = churchesRef.doc();
      final now = DateTime.now();
      await docRef.set({
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        if (placeId != null) 'placeId': placeId,
        'createdAt': Timestamp.fromDate(now),
      });
      return docRef.id;
    } catch (e) {
      throw ChurchException(
        message: 'Failed to create church: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Get all churches for a specific ministry
  Future<List<Map<String, dynamic>>> getChurchesByMinistry(
    String ministryId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('ministries')
          .doc(ministryId)
          .collection('churches')
          .get();

      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();

      // Sort by createdAt descending
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
      throw ChurchException(
        message: 'Failed to get churches: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Get all churches accessible by a user
  /// This queries churches across all ministries where the user is administrator
  Future<List<Map<String, dynamic>>> getChurchesByUser(String userId) async {
    try {
      // First, get all ministries where user is administrator
      final ministriesSnapshot = await _firestore
          .collection('ministries')
          .where('administratorId', isEqualTo: userId)
          .get();

      if (ministriesSnapshot.docs.isEmpty) {
        return [];
      }

      // Then, get churches from each ministry
      final List<Map<String, dynamic>> allChurches = [];
      for (final ministryDoc in ministriesSnapshot.docs) {
        final churchesSnapshot = await ministryDoc.reference
            .collection('churches')
            .get();
        for (final churchDoc in churchesSnapshot.docs) {
          final data = churchDoc.data();
          allChurches.add({
            'id': churchDoc.id,
            'ministryId': ministryDoc.id,
            ...data,
          });
        }
      }

      // Sort by createdAt descending
      allChurches.sort((a, b) {
        final aCreatedAt = a['createdAt'] as Timestamp?;
        final bCreatedAt = b['createdAt'] as Timestamp?;
        if (aCreatedAt == null && bCreatedAt == null) return 0;
        if (aCreatedAt == null) return 1;
        if (bCreatedAt == null) return -1;
        return bCreatedAt.compareTo(aCreatedAt);
      });

      return allChurches;
    } catch (e) {
      throw ChurchException(
        message: 'Failed to get churches by user: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Watch all churches for a specific ministry for real-time updates
  Stream<List<Map<String, dynamic>>> watchChurchesByMinistry(
    String ministryId,
  ) {
    try {
      return _firestore
          .collection('ministries')
          .doc(ministryId)
          .collection('churches')
          .snapshots()
          .map((snapshot) {
            final results = snapshot.docs.map((doc) {
              final data = doc.data();
              return {'id': doc.id, ...data};
            }).toList();

            // Sort by createdAt descending
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
            throw ChurchException(
              message: 'Failed to watch churches: ${error.toString()}',
              cause: error,
            );
          });
    } catch (e) {
      throw ChurchException(
        message: 'Failed to watch churches: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Watch all churches accessible by a user for real-time updates
  Stream<List<Map<String, dynamic>>> watchChurchesByUser(String userId) {
    try {
      // Watch ministries where user is administrator
      return _firestore
          .collection('ministries')
          .where('administratorId', isEqualTo: userId)
          .snapshots()
          .asyncMap((ministriesSnapshot) async {
            if (ministriesSnapshot.docs.isEmpty) {
              return <Map<String, dynamic>>[];
            }

            // Get churches from all ministries
            final List<Map<String, dynamic>> allChurches = [];
            for (final ministryDoc in ministriesSnapshot.docs) {
              final churchesSnapshot = await ministryDoc.reference
                  .collection('churches')
                  .get();
              for (final churchDoc in churchesSnapshot.docs) {
                final data = churchDoc.data();
                allChurches.add({
                  'id': churchDoc.id,
                  'ministryId': ministryDoc.id,
                  ...data,
                });
              }
            }

            // Sort by createdAt descending
            allChurches.sort((a, b) {
              final aCreatedAt = a['createdAt'] as Timestamp?;
              final bCreatedAt = b['createdAt'] as Timestamp?;
              if (aCreatedAt == null && bCreatedAt == null) return 0;
              if (aCreatedAt == null) return 1;
              if (bCreatedAt == null) return -1;
              return bCreatedAt.compareTo(aCreatedAt);
            });

            return allChurches;
          })
          .handleError((error) {
            throw ChurchException(
              message: 'Failed to watch churches by user: ${error.toString()}',
              cause: error,
            );
          });
    } catch (e) {
      throw ChurchException(
        message: 'Failed to watch churches by user: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Get a single church by ID
  Future<Map<String, dynamic>?> getChurch(
    String ministryId,
    String churchId,
  ) async {
    try {
      final doc = await _firestore
          .collection('ministries')
          .doc(ministryId)
          .collection('churches')
          .doc(churchId)
          .get();
      if (!doc.exists) {
        return null;
      }
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw ChurchException(
        message: 'Failed to get church: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Watch a single church by ID for real-time updates
  Stream<Map<String, dynamic>?> watchChurch(
    String ministryId,
    String churchId,
  ) {
    try {
      return _firestore
          .collection('ministries')
          .doc(ministryId)
          .collection('churches')
          .doc(churchId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              return null;
            }
            return {'id': snapshot.id, ...snapshot.data()!};
          })
          .handleError((error) {
            throw ChurchException(
              message: 'Failed to watch church: ${error.toString()}',
              cause: error,
            );
          });
    } catch (e) {
      throw ChurchException(
        message: 'Failed to watch church: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Update church information
  Future<void> updateChurch({
    required String ministryId,
    required String churchId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? placeId,
    String? newMinistryId,
  }) async {
    try {
      final churchRef = _firestore
          .collection('ministries')
          .doc(ministryId)
          .collection('churches')
          .doc(churchId);

      // If moving to a new ministry, we need to copy and delete
      if (newMinistryId != null && newMinistryId != ministryId) {
        // Get current church data
        final currentData = await churchRef.get();
        if (!currentData.exists) {
          throw ChurchException(message: 'Church not found');
        }

        final data = currentData.data()!;
        final updatedData = <String, dynamic>{
          ...data,
          if (name != null) 'name': name,
          if (address != null) 'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (placeId != null) 'placeId': placeId,
        };

        // Create in new ministry
        await _firestore
            .collection('ministries')
            .doc(newMinistryId)
            .collection('churches')
            .doc(churchId)
            .set(updatedData);

        // Delete from old ministry
        await churchRef.delete();
      } else {
        // Update in place
        final updateData = <String, dynamic>{};
        if (name != null) updateData['name'] = name;
        if (address != null) updateData['address'] = address;
        if (latitude != null) updateData['latitude'] = latitude;
        if (longitude != null) updateData['longitude'] = longitude;
        if (placeId != null) updateData['placeId'] = placeId;

        if (updateData.isNotEmpty) {
          await churchRef.update(updateData);
        }
      }
    } catch (e) {
      throw ChurchException(
        message: 'Failed to update church: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Delete a church
  Future<void> deleteChurch(String ministryId, String churchId) async {
    try {
      await _firestore
          .collection('ministries')
          .doc(ministryId)
          .collection('churches')
          .doc(churchId)
          .delete();
    } catch (e) {
      throw ChurchException(
        message: 'Failed to delete church: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Get the count of churches for a ministry
  Future<int> getChurchesCountByMinistry(String ministryId) async {
    try {
      final snapshot = await _firestore
          .collection('ministries')
          .doc(ministryId)
          .collection('churches')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw ChurchException(
        message: 'Failed to get churches count: ${e.toString()}',
        cause: e,
      );
    }
  }

  /// Reassign churches from one ministry to another
  Future<void> reassignChurchesToMinistry({
    required String fromMinistryId,
    required String toMinistryId,
  }) async {
    try {
      // Get all churches from source ministry
      final churchesSnapshot = await _firestore
          .collection('ministries')
          .doc(fromMinistryId)
          .collection('churches')
          .get();

      // Batch write to move all churches
      final batch = _firestore.batch();
      for (final churchDoc in churchesSnapshot.docs) {
        final data = churchDoc.data();
        final newChurchRef = _firestore
            .collection('ministries')
            .doc(toMinistryId)
            .collection('churches')
            .doc(churchDoc.id);
        batch.set(newChurchRef, data);
        batch.delete(churchDoc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw ChurchException(
        message: 'Failed to reassign churches: ${e.toString()}',
        cause: e,
      );
    }
  }
}
