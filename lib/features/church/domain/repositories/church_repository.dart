import '../entities/church.dart';
import '../entities/location.dart';

/// Repository interface for church operations
abstract class ChurchRepository {
  /// Create a new church
  Future<Church> createChurch({
    required String name,
    required Location location,
    required String ministryId,
  });

  /// Get all churches accessible by a user
  /// This queries churches across all ministries the user has access to
  Future<List<Church>> getChurchesByUser(String userId);

  /// Get all churches for a specific ministry
  Future<List<Church>> getChurchesByMinistry(String ministryId);

  /// Watch all churches accessible by a user for real-time updates
  Stream<List<Church>> watchChurchesByUser(String userId);

  /// Watch all churches for a specific ministry for real-time updates
  Stream<List<Church>> watchChurchesByMinistry(String ministryId);

  /// Get a single church by ID
  Future<Church?> getChurch(String ministryId, String churchId);

  /// Watch a single church by ID for real-time updates
  Stream<Church?> watchChurch(String ministryId, String churchId);

  /// Update church information
  Future<void> updateChurch({
    required String ministryId,
    required String churchId,
    String? name,
    Location? location,
    String? newMinistryId,
  });

  /// Delete a church
  Future<void> deleteChurch(String ministryId, String churchId);

  /// Get the count of churches for a ministry
  Future<int> getChurchesCountByMinistry(String ministryId);

  /// Reassign churches from one ministry to another
  Future<void> reassignChurchesToMinistry({
    required String fromMinistryId,
    required String toMinistryId,
  });
}
