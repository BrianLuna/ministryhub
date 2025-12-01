import 'package:equatable/equatable.dart';

/// Represents a geographical location
class Location extends Equatable {
  const Location({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  /// Full address string
  final String address;

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Google Places ID (optional)
  final String? placeId;

  @override
  List<Object?> get props => [address, latitude, longitude, placeId];
}
