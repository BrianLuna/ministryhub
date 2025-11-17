import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required SignInWithEmailUseCase signInWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignOutUseCase signOutUseCase,
    required WatchAuthStateUseCase watchAuthStateUseCase,
  }) : _signInWithEmail = signInWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signOutUseCase = signOutUseCase,
       _watchAuthStateUseCase = watchAuthStateUseCase,
       super(const AuthState.initial()) {
    _authSubscription = _watchAuthStateUseCase().listen(_onAuthStateChange);
  }

  final SignInWithEmailUseCase _signInWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOutUseCase;
  final WatchAuthStateUseCase _watchAuthStateUseCase;

  StreamSubscription<AuthUser?>? _authSubscription;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, resetError: true);
    try {
      final user = await _signInWithEmail(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user ?? state.user,
      );
    } on AuthFailure catch (error) {
      state = state.copyWith(status: AuthStatus.error, errorCode: error.code);
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: AuthErrorCodes.generic,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, resetError: true);
    try {
      final user = await _signInWithGoogle();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user ?? state.user,
      );
    } on AuthFailure catch (error) {
      state = state.copyWith(status: AuthStatus.error, errorCode: error.code);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: AuthErrorCodes.generic,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading, resetError: true);
    try {
      await _signOutUseCase();
      state = state.copyWith(status: AuthStatus.idle, removeUser: true);
    } on AuthFailure catch (error) {
      state = state.copyWith(status: AuthStatus.error, errorCode: error.code);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: AuthErrorCodes.generic,
      );
    }
  }

  void clearError() {
    if (state.errorCode != null) {
      state = state.copyWith(resetError: true);
    }
  }

  void _onAuthStateChange(AuthUser? user) {
    final nextStatus = state.isLoading
        ? state.status
        : (user == null ? AuthStatus.idle : AuthStatus.authenticated);

    state = state.copyWith(
      user: user,
      status: nextStatus,
      removeUser: user == null,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(firebaseAuthDatasourceProvider);
  return AuthRepositoryImpl(datasource);
});

final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithEmailUseCase(repository);
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogleUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final watchAuthStateUseCaseProvider = Provider<WatchAuthStateUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return WatchAuthStateUseCase(repository);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      signInWithEmail: ref.read(signInWithEmailUseCaseProvider),
      signInWithGoogle: ref.read(signInWithGoogleUseCaseProvider),
      signOutUseCase: ref.read(signOutUseCaseProvider),
      watchAuthStateUseCase: ref.read(watchAuthStateUseCaseProvider),
    );
  },
);
