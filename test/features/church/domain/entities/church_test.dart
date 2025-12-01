import 'package:flutter_test/flutter_test.dart';
import 'package:ministryhub/ministryhub.dart';

void main() {
  group('Church', () {
    test('should create a church entity', () {
      final location = Location(
        address: '123 Main St',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      final church = Church(
        id: '1',
        name: 'Test Church',
        location: location,
        ministryId: 'ministry1',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(church.id, '1');
      expect(church.name, 'Test Church');
      expect(church.location, location);
      expect(church.ministryId, 'ministry1');
      expect(church.displayName, 'Test Church');
      expect(church.entityType, EntityType.church);
    });

    test('should implement ReligiousEntity', () {
      final location = Location(
        address: '123 Main St',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      final church = Church(
        id: '1',
        name: 'Test Church',
        location: location,
        ministryId: 'ministry1',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(church, isA<ReligiousEntity>());
    });

    test('should support equality comparison', () {
      final location = Location(
        address: '123 Main St',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      final church1 = Church(
        id: '1',
        name: 'Test Church',
        location: location,
        ministryId: 'ministry1',
        createdAt: DateTime(2024, 1, 1),
      );

      final church2 = Church(
        id: '1',
        name: 'Test Church',
        location: location,
        ministryId: 'ministry1',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(church1, equals(church2));
    });
  });

  group('Location', () {
    test('should create a location entity', () {
      final location = Location(
        address: '123 Main St',
        latitude: 40.7128,
        longitude: -74.0060,
        placeId: 'place123',
      );

      expect(location.address, '123 Main St');
      expect(location.latitude, 40.7128);
      expect(location.longitude, -74.0060);
      expect(location.placeId, 'place123');
    });

    test('should support equality comparison', () {
      final location1 = Location(
        address: '123 Main St',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      final location2 = Location(
        address: '123 Main St',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      expect(location1, equals(location2));
    });
  });
}
