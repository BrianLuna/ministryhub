import 'package:equatable/equatable.dart';
import 'package:ministryhub/ministryhub.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthState extends Equatable {
  const AuthState({required this.status, required this.user, this.errorCode});

  const AuthState.initial()
    : status = AuthStatus.idle,
      user = null,
      errorCode = null;

  final AuthStatus status;
  final AuthUser? user;
  final String? errorCode;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorCode,
    bool resetError = false,
    bool removeUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: removeUser ? null : user ?? this.user,
      errorCode: resetError ? null : errorCode ?? this.errorCode,
    );
  }

  @override
  List<Object?> get props => [status, user, errorCode];
}
