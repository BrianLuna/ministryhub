import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ministryhub/core/router/app_router.dart';
import 'package:ministryhub/l10n/app_localizations.dart';
import 'package:ministryhub/ministryhub.dart';

void main() {
  group('AppRouter', () {
    test('router should not be null', () {
      expect(AppRouter.router, isNotNull);
    });

    test('router should be instance of GoRouter', () {
      expect(AppRouter.router, isA<GoRouter>());
    });

    test('router should be configured', () {
      expect(AppRouter.router, isNotNull);
    });

    testWidgets('router should navigate to login page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('es')],
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the login page is displayed
      expect(find.text('MinistryHub'), findsOneWidget);
    });

    testWidgets('router should have login route configured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('es')],
        ),
      );

      await tester.pumpAndSettle();

      // Check if we can find elements from LoginRegisterPage
      expect(find.text('MinistryHub'), findsOneWidget);
    });
  });
}
