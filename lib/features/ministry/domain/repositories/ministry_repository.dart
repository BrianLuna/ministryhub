import 'package:ministryhub/ministryhub.dart';

/// Repository interface for ministry operations
abstract class MinistryRepository {
  /// Create a new ministry
  Future<Ministry> createMinistry({
    required String name,
    required String administratorId,
  });

  /// Get all ministries where the user is administrator or member
  /// For now, only returns ministries where user is administrator
  /// Future: will also return ministries where user is a member
  Future<List<Ministry>> getMinistriesByUser(String userId);

  /// Get all ministries where the user is administrator
  Future<List<Ministry>> getMinistriesByAdministrator(String userId);

  /// Watch all ministries where the user is administrator or member for real-time updates
  /// For now, only returns ministries where user is administrator
  /// Future: will also return ministries where user is a member
  Stream<List<Ministry>> watchMinistriesByUser(String userId);

  /// Watch all ministries where the user is administrator for real-time updates
  Stream<List<Ministry>> watchMinistriesByAdministrator(String userId);

  /// Get a single ministry by ID
  Future<Ministry?> getMinistry(String ministryId);

  /// Watch a single ministry by ID for real-time updates
  Stream<Ministry?> watchMinistry(String ministryId);

  /// Update ministry name
  Future<void> updateMinistry({
    required String ministryId,
    required String name,
  });

  /// Upload ministry logo to Firebase Storage
  Future<String> uploadMinistryLogo({
    required String ministryId,
    required List<int> imageData,
  });

  /// Delete ministry logo from Firebase Storage
  Future<void> deleteMinistryLogo(String logoPath);

  /// Delete ministry and all associated data
  Future<void> deleteMinistry(String ministryId);
}
