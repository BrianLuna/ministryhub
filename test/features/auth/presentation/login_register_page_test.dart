import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ministryhub/features/auth/domain/entities/auth_user.dart';
import 'package:ministryhub/features/auth/domain/repositories/auth_repository.dart';
import 'package:ministryhub/features/auth/presentation/pages/login_register_page.dart';
import 'package:ministryhub/features/auth/presentation/providers/auth_controller.dart';
import 'package:ministryhub/l10n/app_localizations.dart';

void main() {
  Widget buildSubject() {
    final repository = _StubAuthRepository();
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginRegisterPage(),
      ),
    );
  }

  group('LoginRegisterPage', () {
    testWidgets('renders hero copy and primary actions', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Two SVGs: MinistryHub logotype + Google logo
      expect(find.byType(SvgPicture), findsNWidgets(2));
      expect(find.text('Login / Register'), findsOneWidget);
      expect(find.text('Enter MinistryHub'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('shows email and password inputs', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(SvgPicture), findsNWidgets(2));
    });
  });
}

class _StubAuthRepository implements AuthRepository {
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
}
