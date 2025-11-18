import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required SignInWithEmailUseCase signInWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignOutUseCase signOutUseCase,
    required WatchAuthStateUseCase watchAuthStateUseCase,
    required RegisterWithEmailUseCase registerWithEmailUseCase,
    required SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase,
  }) : _signInWithEmail = signInWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signOutUseCase = signOutUseCase,
       _watchAuthStateUseCase = watchAuthStateUseCase,
       _registerWithEmailUseCase = registerWithEmailUseCase,
       _sendPasswordResetEmailUseCase = sendPasswordResetEmailUseCase,
       super(const AuthState.initial()) {
    _authSubscription = _watchAuthStateUseCase().listen(_onAuthStateChange);
  }

  final SignInWithEmailUseCase _signInWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOutUseCase;
  final WatchAuthStateUseCase _watchAuthStateUseCase;
  final RegisterWithEmailUseCase _registerWithEmailUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;

  StreamSubscription<AuthUser?>? _authSubscription;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      resetError: true,
      showRegistrationPrompt: false,
    );
    try {
      final user = await _signInWithEmail(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user ?? state.user,
        showRegistrationPrompt: false,
      );
    } on AuthFailure catch (error) {
      if (error.code == AuthErrorCodes.userNotFound) {
        state = state.copyWith(
          status: AuthStatus.idle,
          showRegistrationPrompt: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorCode: error.code,
          showRegistrationPrompt: false,
        );
      }
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: AuthErrorCodes.generic,
        showRegistrationPrompt: false,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      resetError: true,
      showRegistrationPrompt: false,
    );
    try {
      final user = await _signInWithGoogle();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user ?? state.user,
        showRegistrationPrompt: false,
      );
    } on AuthFailure catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: error.code,
        showRegistrationPrompt: false,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: AuthErrorCodes.generic,
        showRegistrationPrompt: false,
      );
    }
  }

  Future<void> signOut({PreferencesService? preferencesService}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      resetError: true,
      showRegistrationPrompt: false,
    );
    try {
      // Clear user preferences before signing out
      final userId = state.user?.uid;
      if (userId != null && preferencesService != null) {
        await preferencesService.clearUserPreferences(userId);
      }
      await _signOutUseCase();
      state = state.copyWith(
        status: AuthStatus.idle,
        removeUser: true,
        showRegistrationPrompt: false,
      );
    } on AuthFailure catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: error.code,
        showRegistrationPrompt: false,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: AuthErrorCodes.generic,
        showRegistrationPrompt: false,
      );
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, resetError: true);
    try {
      await _sendPasswordResetEmailUseCase(email: email);
      state = state.copyWith(status: AuthStatus.idle);
    } on AuthFailure catch (error) {
      state = state.copyWith(status: AuthStatus.error, errorCode: error.code);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: AuthErrorCodes.generic,
      );
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      resetError: true,
      showRegistrationPrompt: false,
    );
    try {
      final user = await _registerWithEmailUseCase(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user ?? state.user,
        showRegistrationPrompt: false,
      );
    } on AuthFailure catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: error.code,
        showRegistrationPrompt: false,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorCode: AuthErrorCodes.generic,
        showRegistrationPrompt: false,
      );
    }
  }

  void clearError() {
    if (state.errorCode != null) {
      state = state.copyWith(resetError: true);
    }
  }

  void clearRegistrationPrompt() {
    state = state.copyWith(showRegistrationPrompt: false);
  }

  void _onAuthStateChange(AuthUser? user) {
    final nextStatus = state.isLoading
        ? state.status
        : (user == null ? AuthStatus.idle : AuthStatus.authenticated);

    state = state.copyWith(
      user: user,
      status: nextStatus,
      removeUser: user == null,
      showRegistrationPrompt: user == null
          ? false
          : state.showRegistrationPrompt,
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

final registerWithEmailUseCaseProvider = Provider<RegisterWithEmailUseCase>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterWithEmailUseCase(repository);
});

final sendPasswordResetEmailUseCaseProvider =
    Provider<SendPasswordResetEmailUseCase>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return SendPasswordResetEmailUseCase(repository);
    });

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      signInWithEmail: ref.read(signInWithEmailUseCaseProvider),
      signInWithGoogle: ref.read(signInWithGoogleUseCaseProvider),
      signOutUseCase: ref.read(signOutUseCaseProvider),
      watchAuthStateUseCase: ref.read(watchAuthStateUseCaseProvider),
      registerWithEmailUseCase: ref.read(registerWithEmailUseCaseProvider),
      sendPasswordResetEmailUseCase: ref.read(
        sendPasswordResetEmailUseCaseProvider,
      ),
    );
  },
);
