import 'package:equatable/equatable.dart';

/// Domain representation of an authenticated user.
class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.providerId,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? providerId;

  /// Returns true if the user is linked with Google
  bool get isGoogleUser => providerId == 'google.com';

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, providerId];
}
