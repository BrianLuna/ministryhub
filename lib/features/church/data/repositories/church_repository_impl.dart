import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ministryhub/ministryhub.dart';

/// Implementation of ChurchRepository
class ChurchRepositoryImpl implements ChurchRepository {
  ChurchRepositoryImpl({required ChurchFirestoreDatasource firestoreDatasource})
    : _firestoreDatasource = firestoreDatasource;

  final ChurchFirestoreDatasource _firestoreDatasource;

  @override
  Future<Church> createChurch({
    required String name,
    required Location location,
    required String ministryId,
  }) async {
    try {
      final churchId = await _firestoreDatasource.createChurch(
        name: name,
        address: location.address,
        latitude: location.latitude,
        longitude: location.longitude,
        placeId: location.placeId,
        ministryId: ministryId,
      );

      // Get the created church to return it
      final data = await _firestoreDatasource.getChurch(ministryId, churchId);
      if (data == null) {
        throw ChurchException(message: 'Failed to retrieve created church');
      }

      return _mapToChurch(data, ministryId);
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to create church: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<List<Church>> getChurchesByUser(String userId) async {
    try {
      final dataList = await _firestoreDatasource.getChurchesByUser(userId);
      return dataList
          .map((data) => _mapToChurch(data, data['ministryId'] as String))
          .toList();
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to get churches: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<List<Church>> getChurchesByMinistry(String ministryId) async {
    try {
      final dataList = await _firestoreDatasource.getChurchesByMinistry(
        ministryId,
      );
      return dataList.map((data) => _mapToChurch(data, ministryId)).toList();
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to get churches: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Stream<List<Church>> watchChurchesByUser(String userId) {
    try {
      return _firestoreDatasource.watchChurchesByUser(userId).map((dataList) {
        try {
          return dataList
              .map((data) => _mapToChurch(data, data['ministryId'] as String))
              .toList();
        } catch (e) {
          if (e is ChurchException) {
            rethrow;
          }
          throw ChurchException(
            message: 'Failed to map churches: ${e.toString()}',
            cause: e,
          );
        }
      });
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to watch churches: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Stream<List<Church>> watchChurchesByMinistry(String ministryId) {
    try {
      return _firestoreDatasource.watchChurchesByMinistry(ministryId).map((
        dataList,
      ) {
        try {
          return dataList
              .map((data) => _mapToChurch(data, ministryId))
              .toList();
        } catch (e) {
          if (e is ChurchException) {
            rethrow;
          }
          throw ChurchException(
            message: 'Failed to map churches: ${e.toString()}',
            cause: e,
          );
        }
      });
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to watch churches: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<Church?> getChurch(String ministryId, String churchId) async {
    try {
      final data = await _firestoreDatasource.getChurch(ministryId, churchId);
      if (data == null) {
        return null;
      }
      return _mapToChurch(data, ministryId);
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to get church: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Stream<Church?> watchChurch(String ministryId, String churchId) {
    try {
      return _firestoreDatasource.watchChurch(ministryId, churchId).map((data) {
        if (data == null) {
          return null;
        }
        try {
          return _mapToChurch(data, ministryId);
        } catch (e) {
          if (e is ChurchException) {
            rethrow;
          }
          throw ChurchException(
            message: 'Failed to map church: ${e.toString()}',
            cause: e,
          );
        }
      });
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to watch church: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> updateChurch({
    required String ministryId,
    required String churchId,
    String? name,
    Location? location,
    String? newMinistryId,
  }) async {
    try {
      await _firestoreDatasource.updateChurch(
        ministryId: ministryId,
        churchId: churchId,
        name: name,
        address: location?.address,
        latitude: location?.latitude,
        longitude: location?.longitude,
        placeId: location?.placeId,
        newMinistryId: newMinistryId,
      );
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to update church: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteChurch(String ministryId, String churchId) async {
    try {
      await _firestoreDatasource.deleteChurch(ministryId, churchId);
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to delete church: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<int> getChurchesCountByMinistry(String ministryId) async {
    try {
      return await _firestoreDatasource.getChurchesCountByMinistry(ministryId);
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to get churches count: ${e.toString()}',
        cause: e,
      );
    }
  }

  @override
  Future<void> reassignChurchesToMinistry({
    required String fromMinistryId,
    required String toMinistryId,
  }) async {
    try {
      await _firestoreDatasource.reassignChurchesToMinistry(
        fromMinistryId: fromMinistryId,
        toMinistryId: toMinistryId,
      );
    } catch (e) {
      if (e is ChurchException) {
        rethrow;
      }
      throw ChurchException(
        message: 'Failed to reassign churches: ${e.toString()}',
        cause: e,
      );
    }
  }

  Church _mapToChurch(Map<String, dynamic> data, String ministryId) {
    final createdAt = data['createdAt'];
    DateTime createdAtDate;
    if (createdAt is Timestamp) {
      createdAtDate = createdAt.toDate();
    } else if (createdAt is DateTime) {
      createdAtDate = createdAt;
    } else {
      throw ChurchException(message: 'Invalid createdAt format in church data');
    }

    final location = Location(
      address: data['address'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      placeId: data['placeId'] as String?,
    );

    return Church(
      id: data['id'] as String,
      name: data['name'] as String,
      location: location,
      ministryId: ministryId,
      createdAt: createdAtDate,
    );
  }
}
