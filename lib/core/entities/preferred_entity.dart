import 'package:equatable/equatable.dart';
import 'entity_type.dart';

/// Represents a preferred entity (ministry or church) selected by the user
class PreferredEntity extends Equatable {
  const PreferredEntity({required this.id, required this.type});

  /// Entity identifier
  final String id;

  /// Entity type (ministry or church)
  final EntityType type;

  @override
  List<Object?> get props => [id, type];
}
