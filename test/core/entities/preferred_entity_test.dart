import 'package:flutter_test/flutter_test.dart';
import 'package:ministryhub/ministryhub.dart';

void main() {
  group('PreferredEntity', () {
    test('should create a preferred entity with ministry type', () {
      final entity = PreferredEntity(
        id: 'ministry1',
        type: EntityType.ministry,
      );

      expect(entity.id, 'ministry1');
      expect(entity.type, EntityType.ministry);
    });

    test('should create a preferred entity with church type', () {
      final entity = PreferredEntity(id: 'church1', type: EntityType.church);

      expect(entity.id, 'church1');
      expect(entity.type, EntityType.church);
    });

    test('should support equality comparison', () {
      final entity1 = PreferredEntity(
        id: 'ministry1',
        type: EntityType.ministry,
      );

      final entity2 = PreferredEntity(
        id: 'ministry1',
        type: EntityType.ministry,
      );

      expect(entity1, equals(entity2));
    });

    test('should not be equal if id differs', () {
      final entity1 = PreferredEntity(
        id: 'ministry1',
        type: EntityType.ministry,
      );

      final entity2 = PreferredEntity(
        id: 'ministry2',
        type: EntityType.ministry,
      );

      expect(entity1, isNot(equals(entity2)));
    });

    test('should not be equal if type differs', () {
      final entity1 = PreferredEntity(id: 'entity1', type: EntityType.ministry);

      final entity2 = PreferredEntity(id: 'entity1', type: EntityType.church);

      expect(entity1, isNot(equals(entity2)));
    });
  });
}
