import 'package:equatable/equatable.dart';
import 'package:ministryhub/ministryhub.dart';

/// Domain entity representing a ministry
class Ministry extends Equatable {
  const Ministry({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.administratorId,
    this.logoUrl,
    this.subscriptionType = SubscriptionType.free,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final String administratorId;
  final String? logoUrl;
  final SubscriptionType subscriptionType;

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
