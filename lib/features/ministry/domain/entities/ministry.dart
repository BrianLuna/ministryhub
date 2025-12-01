import 'package:equatable/equatable.dart';
import 'package:ministryhub/ministryhub.dart';

/// Domain entity representing a ministry
class Ministry extends Equatable implements ReligiousEntity {
  const Ministry({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.administratorId,
    this.logoUrl,
    this.subscriptionType = SubscriptionType.free,
  });

  @override
  final String id;
  @override
  final String name;
  final DateTime createdAt;
  final String administratorId;
  final String? logoUrl;
  final SubscriptionType subscriptionType;

  @override
  String get displayName => name;

  @override
  EntityType get entityType => EntityType.ministry;

  @override
  List<Object?> get props => [
    id,
    name,
    createdAt,
    administratorId,
    logoUrl,
    subscriptionType,
  ];
}
