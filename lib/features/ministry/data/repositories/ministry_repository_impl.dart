import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ministryhub/ministryhub.dart';

/// Implementation of MinistryRepository
class MinistryRepositoryImpl implements MinistryRepository {
  MinistryRepositoryImpl({
    required MinistryFirestoreDatasource firestoreDatasource,
    required MinistryStorageDatasource storageDatasource,
  }) : _firestoreDatasource = firestoreDatasource,
       _storageDatasource = storageDatasource;

  final MinistryFirestoreDatasource _firestoreDatasource;
  final MinistryStorageDatasource _storageDatasource;

  @override
  Future<Ministry> createMinistry({
    required String name,
    required String administratorId,
  }) async {
    try {
      final ministryId = await _firestoreDatasource.createMinistry(
        name: name,
        administratorId: administratorId,
      );

      // Get the created ministry to return it
      final data = await _firestoreDatasource.getMinistry(ministryId);
      if (data == null) {
        throw MinistryException(message: 'Failed to retrieve created ministry');
      }

      return _mapToMinistry(data);
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to create ministry: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<List<Ministry>> getMinistriesByUser(String userId) async {
    try {
      final dataList = await _firestoreDatasource.getMinistriesByUser(userId);
      return dataList.map(_mapToMinistry).toList();
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to get ministries: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Stream<List<Ministry>> watchMinistriesByUser(String userId) {
    try {
      return _firestoreDatasource.watchMinistriesByUser(userId).map((dataList) {
        try {
          return dataList.map(_mapToMinistry).toList();
        } catch (e) {
          if (e is MinistryException) {
            rethrow;
          }
          throw MinistryException(
            message: 'Failed to map ministries: ${e.toString()}',
            cause: e,
          );
        }
      });
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to watch ministries: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<List<Ministry>> getMinistriesByAdministrator(String userId) async {
    try {
      final dataList = await _firestoreDatasource.getMinistriesByAdministrator(
        userId,
      );
      return dataList.map(_mapToMinistry).toList();
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to get ministries: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Stream<List<Ministry>> watchMinistriesByAdministrator(String userId) {
    try {
      return _firestoreDatasource.watchMinistriesByAdministrator(userId).map((
        dataList,
      ) {
        try {
          return dataList.map(_mapToMinistry).toList();
        } catch (e) {
          if (e is MinistryException) {
            rethrow;
          }
          throw MinistryException(
            message: 'Failed to map ministries: ${e.toString()}',
            cause: e,
          );
        }
      });
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to watch ministries: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<Ministry?> getMinistry(String ministryId) async {
    try {
      final data = await _firestoreDatasource.getMinistry(ministryId);
      if (data == null) {
        return null;
      }
      return _mapToMinistry(data);
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to get ministry: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Stream<Ministry?> watchMinistry(String ministryId) {
    try {
      return _firestoreDatasource.watchMinistry(ministryId).map((data) {
        if (data == null) {
          return null;
        }
        try {
          return _mapToMinistry(data);
        } catch (e) {
          if (e is MinistryException) {
            rethrow;
          }
          throw MinistryException(
            message: 'Failed to map ministry: ${e.toString()}',
            cause: e,
          );
        }
      });
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to watch ministry: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> updateMinistry({
    required String ministryId,
    required String name,
  }) async {
    try {
      await _firestoreDatasource.updateMinistry(
        ministryId: ministryId,
        name: name,
      );
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to update ministry: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<String> uploadMinistryLogo({
    required String ministryId,
    required List<int> imageData,
  }) async {
    try {
      // Upload logo and get download URL
      final downloadUrl = await _storageDatasource.uploadMinistryLogo(
        ministryId: ministryId,
        imageData: imageData,
      );

      // Save the logo URL to Firestore
      await _firestoreDatasource.updateMinistryLogoUrl(
        ministryId: ministryId,
        logoUrl: downloadUrl,
      );

      return downloadUrl;
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to upload ministry logo: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteMinistryLogo(String logoPath) async {
    try {
      await _storageDatasource.deleteMinistryLogo(logoPath);
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to delete ministry logo: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> removeMinistryLogo(String ministryId) async {
    try {
      // Get ministry to find logo URL
      final ministryData = await _firestoreDatasource.getMinistry(ministryId);
      if (ministryData != null) {
        final logoUrl = ministryData['logoUrl'] as String?;
        if (logoUrl != null && logoUrl.isNotEmpty) {
          // Delete logo from storage
          await _storageDatasource.deleteMinistryLogo(logoUrl);
        }
      }
      // Remove logo URL from Firestore
      await _firestoreDatasource.removeMinistryLogoUrl(ministryId);
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to remove ministry logo: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> updateMinistrySubscriptionType({
    required String ministryId,
    required SubscriptionType subscriptionType,
  }) async {
    try {
      await _firestoreDatasource.updateMinistrySubscriptionType(
        ministryId: ministryId,
        subscriptionType: subscriptionType,
      );
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to update ministry subscription: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteMinistry(String ministryId) async {
    try {
      // Get ministry to check for logo
      final ministry = await getMinistry(ministryId);

      // Delete logo from Storage if exists
      if (ministry?.logoUrl != null) {
        try {
          await _storageDatasource.deleteMinistryLogo(ministry!.logoUrl!);
        } catch (e) {
          // Log but don't fail if logo deletion fails
          // Continue with ministry deletion
        }
      } else {
        // Try to delete using default path if logoUrl doesn't exist
        try {
          await _storageDatasource.deleteMinistryLogo(
            'ministries/$ministryId/logo.jpg',
          );
        } catch (e) {
          // Ignore if file doesn't exist
        }
      }

      // Delete ministry from Firestore
      await _firestoreDatasource.deleteMinistry(ministryId);
    } catch (e) {
      if (e is MinistryException) {
        rethrow;
      }
      throw MinistryException(
        message: 'Failed to delete ministry: ${e.toString()}',
        cause: e,
      );
    }
  }

  Ministry _mapToMinistry(Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    DateTime createdAtDate;
    if (createdAt is Timestamp) {
      createdAtDate = createdAt.toDate();
    } else if (createdAt is DateTime) {
      createdAtDate = createdAt;
    } else {
      throw MinistryException(
        message: 'Invalid createdAt format in ministry data',
      );
    }

    final subscriptionTypeString = data['subscriptionType'] as String?;
    final subscriptionType = subscriptionTypeString != null
        ? SubscriptionType.fromString(subscriptionTypeString)
        : SubscriptionType.free;

    return Ministry(
      id: data['id'] as String,
      name: data['name'] as String,
      createdAt: createdAtDate,
      administratorId: data['administratorId'] as String,
      logoUrl: data['logoUrl'] as String?,
      subscriptionType: subscriptionType,
    );
  }
}
