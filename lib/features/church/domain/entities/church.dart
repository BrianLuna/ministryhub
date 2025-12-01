import 'package:equatable/equatable.dart';
import 'package:ministryhub/ministryhub.dart';

/// Domain entity representing a church
class Church extends Equatable implements ReligiousEntity {
  const Church({
    required this.id,
    required this.name,
    required this.location,
    required this.ministryId,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String name;
  final Location location;
  final String ministryId;
  final DateTime createdAt;

  @override
  String get displayName => name;

  @override
  EntityType get entityType => EntityType.church;

  @override
  List<Object?> get props => [id, name, location, ministryId, createdAt];
}
