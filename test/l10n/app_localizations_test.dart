import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ministryhub/l10n/app_localizations.dart';

void main() {
  Widget createTestWidget({required Locale locale, required Widget child}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: child,
    );
  }

  group('AppLocalizations', () {
    testWidgets('should load English localizations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('en'),
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.appTitle);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('MinistryHub'), findsOneWidget);
    });

    testWidgets('should load Spanish localizations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('es'),
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.loginRegisterTitle);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Inicio de Sesión / Registro'), findsOneWidget);
    });

    testWidgets('should have correct English translations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('en'),
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  Text(l10n.appTitle),
                  Text(l10n.loginRegisterTitle),
                  Text(l10n.welcome),
                  Text(l10n.loginRegisterFormPlaceholder),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('MinistryHub'), findsOneWidget);
      expect(find.text('Login / Register'), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Login/Register form'), findsOneWidget);
    });

    testWidgets('should have correct Spanish translations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('es'),
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  Text(l10n.appTitle),
                  Text(l10n.loginRegisterTitle),
                  Text(l10n.welcome),
                  Text(l10n.loginRegisterFormPlaceholder),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('MinistryHub'), findsOneWidget);
      expect(find.text('Inicio de Sesión / Registro'), findsOneWidget);
      expect(find.text('Bienvenido'), findsOneWidget);
      expect(
        find.text('Formulario de inicio de sesión/registro'),
        findsOneWidget,
      );
    });

    testWidgets('should fallback to English for unsupported locale', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('es')],
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n?.appTitle ?? '');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should fallback to English
      expect(find.text('MinistryHub'), findsOneWidget);
    });

    test('delegate should not be null', () {
      expect(AppLocalizations.delegate, isNotNull);
    });

    test('supportedLocales should include en and es', () {
      final supportedLocales = AppLocalizations.supportedLocales;
      expect(supportedLocales, contains(const Locale('en')));
      expect(supportedLocales, contains(const Locale('es')));
    });
  });
}
