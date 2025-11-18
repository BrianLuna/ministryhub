import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ministryhub/ministryhub.dart';

void main() {
  group('AuthController', () {
    test('signInWithEmail success updates state', () async {
      final repository = _FakeAuthRepository()
        ..emailUser = const AuthUser(uid: '1', email: 'user@test.com');
      final controller = _buildController(repository);

      await controller.signInWithEmail(
        email: 'user@test.com',
        password: '12345678',
      );

      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.user?.email, 'user@test.com');
      controller.dispose();
      await repository.dispose();
    });

    test('signInWithEmail failure exposes error code', () async {
      final repository = _FakeAuthRepository()
        ..signInFailure = const AuthFailure(code: AuthErrorCodes.invalidEmail);
      final controller = _buildController(repository);

      await controller.signInWithEmail(email: 'bad', password: '12345678');

      expect(controller.state.status, AuthStatus.error);
      expect(controller.state.errorCode, AuthErrorCodes.invalidEmail);
      controller.dispose();
      await repository.dispose();
    });

    test('signInWithGoogle success updates state', () async {
      final repository = _FakeAuthRepository()
        ..googleUser = const AuthUser(uid: '2', email: 'google@test.com');
      final controller = _buildController(repository);

      await controller.signInWithGoogle();

      expect(controller.state.user?.uid, '2');
      expect(controller.state.status, AuthStatus.authenticated);
      controller.dispose();
      await repository.dispose();
    });

    test('signOut resets state', () async {
      final repository = _FakeAuthRepository()
        ..emailUser = const AuthUser(uid: '1', email: 'user@test.com');
      final controller = _buildController(repository);

      await controller.signInWithEmail(
        email: 'user@test.com',
        password: '12345678',
      );
      await controller.signOut();

      expect(controller.state.user, isNull);
      expect(controller.state.status, AuthStatus.idle);
      controller.dispose();
      await repository.dispose();
    });

    test('signInWithEmail user-not-found shows registration prompt', () async {
      final repository = _FakeAuthRepository()
        ..signInFailure = const AuthFailure(code: AuthErrorCodes.userNotFound);
      final controller = _buildController(repository);

      await controller.signInWithEmail(
        email: 'new@test.com',
        password: '12345678',
      );

      expect(controller.state.status, AuthStatus.idle);
      expect(controller.state.showRegistrationPrompt, isTrue);
      controller.dispose();
      await repository.dispose();
    });
  });
}

AuthController _buildController(_FakeAuthRepository repository) {
  return AuthController(
    signInWithEmail: SignInWithEmailUseCase(repository),
    signInWithGoogle: SignInWithGoogleUseCase(repository),
    signOutUseCase: SignOutUseCase(repository),
    watchAuthStateUseCase: WatchAuthStateUseCase(repository),
    registerWithEmailUseCase: RegisterWithEmailUseCase(repository),
    sendPasswordResetEmailUseCase: SendPasswordResetEmailUseCase(repository),
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository()
    : _authController = StreamController<AuthUser?>.broadcast() {
    _authController.add(null);
  }

  final StreamController<AuthUser?> _authController;
  AuthUser? emailUser;
  AuthUser? googleUser;
  AuthFailure? signInFailure;
  AuthFailure? googleFailure;
  AuthFailure? signOutFailure;
  AuthUser? _currentUser;

  Future<void> dispose() async {
    await _authController.close();
  }

  @override
  Stream<AuthUser?> authStateChanges() => _authController.stream;

  @override
  Future<AuthUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (signInFailure != null) {
      throw signInFailure!;
    }
    _currentUser = emailUser;
    _authController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    if (googleFailure != null) {
      throw googleFailure!;
    }
    _currentUser = googleUser;
    _authController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    if (signOutFailure != null) {
      throw signOutFailure!;
    }
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<AuthUser?> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async => null;
}
