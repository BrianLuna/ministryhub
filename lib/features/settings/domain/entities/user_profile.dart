import 'package:equatable/equatable.dart';

/// Domain entity representing user profile information
class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    this.firstName,
    this.lastName,
    this.email,
    this.photoUrl,
    this.profilePhotoPath,
  });

  final String uid;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? photoUrl;
  final String? profilePhotoPath;

  /// Full name combining first and last name
  String? get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName;
    if (lastName != null) return lastName;
    return null;
  }

  @override
  List<Object?> get props => [
    uid,
    firstName,
    lastName,
    email,
    photoUrl,
    profilePhotoPath,
  ];
}
