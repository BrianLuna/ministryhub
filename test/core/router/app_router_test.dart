import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ministryhub/core/router/app_router.dart';
import 'package:ministryhub/features/auth/domain/entities/auth_user.dart';
import 'package:ministryhub/features/auth/domain/repositories/auth_repository.dart';
import 'package:ministryhub/features/auth/presentation/providers/auth_controller.dart';
import 'package:ministryhub/l10n/app_localizations.dart';

void main() {
  group('AppRouter', () {
    testWidgets('router should navigate to login page', (tester) async {
      // Build the widget using the router
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _RouterAuthRepositoryStub(),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if we can find elements from LoginRegisterPage
      expect(find.text('MinistryHub'), findsOneWidget);
    });

    testWidgets('router should have login route configured', (tester) async {
      expect(
        AppRouter.router.routerDelegate.currentConfiguration.uri.toString(),
        '/login',
      );
    });
  });
}

class _RouterAuthRepositoryStub implements AuthRepository {
  @override
  Stream<AuthUser?> authStateChanges() => Stream<AuthUser?>.value(null);

  @override
  Future<AuthUser?> signInWithEmail({
    required String email,
    required String password,
  }) async => null;

  @override
  Future<AuthUser?> signInWithGoogle() async => null;

  @override
  Future<void> signOut() async {}

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
