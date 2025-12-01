import 'entity_type.dart';

/// Interface for religious entities that can be used polymorphically
/// This allows Ministry and Church to be treated uniformly in various contexts
abstract class ReligiousEntity {
  /// Unique identifier of the entity
  String get id;

  /// Name of the entity
  String get name;

  /// Display name for UI purposes (can be same as name or customized)
  String get displayName;

  /// Type of entity (ministry or church)
  EntityType get entityType;
}
