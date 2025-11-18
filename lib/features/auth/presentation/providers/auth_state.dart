import 'package:equatable/equatable.dart';
import 'package:ministryhub/ministryhub.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    required this.user,
    this.errorCode,
    this.showRegistrationPrompt = false,
  });

  const AuthState.initial()
    : status = AuthStatus.idle,
      user = null,
      errorCode = null,
      showRegistrationPrompt = false;

  final AuthStatus status;
  final AuthUser? user;
  final String? errorCode;
  final bool showRegistrationPrompt;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorCode,
    bool? showRegistrationPrompt,
    bool resetError = false,
    bool removeUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: removeUser ? null : user ?? this.user,
      errorCode: resetError ? null : errorCode ?? this.errorCode,
      showRegistrationPrompt:
          showRegistrationPrompt ?? this.showRegistrationPrompt,
    );
  }

  @override
  List<Object?> get props => [status, user, errorCode, showRegistrationPrompt];
}
