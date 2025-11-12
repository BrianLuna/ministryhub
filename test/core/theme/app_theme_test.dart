import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ministryhub/core/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('should have correct Matisse color values', () {
      expect(AppColors.matisse50, const Color(0xFFF2F8FD));
      expect(AppColors.matisse100, const Color(0xFFE5F0F9));
      expect(AppColors.matisse200, const Color(0xFFC5E0F2));
      expect(AppColors.matisse300, const Color(0xFF91C7E8));
      expect(AppColors.matisse400, const Color(0xFF56A9DA));
      expect(AppColors.matisse500, const Color(0xFF318FC6));
      expect(AppColors.matisse600, const Color(0xFF2172A8));
      expect(AppColors.matisse700, const Color(0xFF1F6597));
      expect(AppColors.matisse800, const Color(0xFF1B4E71));
      expect(AppColors.matisse900, const Color(0xFF1B425F));
      expect(AppColors.matisse950, const Color(0xFF122A3F));
    });

    test('should have correct light theme colors', () {
      expect(AppColors.lightBackground, const Color(0xFFFFFFFF));
      expect(AppColors.lightSurface, const Color(0xFFF5F5F5));
      expect(AppColors.lightOnBackground, const Color(0xFF1A1A1A));
      expect(AppColors.lightOnSurface, const Color(0xFF1A1A1A));
    });

    test('should have correct dark theme colors', () {
      expect(AppColors.darkBackground, const Color(0xFF121212));
      expect(AppColors.darkSurface, const Color(0xFF1E1E1E));
      expect(AppColors.darkOnBackground, const Color(0xFFFFFFFF));
      expect(AppColors.darkOnSurface, const Color(0xFFFFFFFF));
    });
  });

  group('AppTheme', () {
    testWidgets('lightTheme getter should exist', (WidgetTester tester) async {
      expect(AppTheme.lightTheme, isA<ThemeData>());
    });

    testWidgets('darkTheme getter should exist', (WidgetTester tester) async {
      expect(AppTheme.darkTheme, isA<ThemeData>());
    });

    testWidgets('lightTheme should have correct brightness', (
      WidgetTester tester,
    ) async {
      // Use testWidgets to properly handle Google Fonts loading
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('lightTheme should use Material 3', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('lightTheme should have correct primary color', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, AppColors.matisse600);
    });

    testWidgets('lightTheme should have correct scaffold background color', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.lightTheme;
      expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);
    });

    testWidgets('lightTheme should have correct card color', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.lightTheme;
      expect(theme.cardColor, AppColors.lightSurface);
    });

    testWidgets('lightTheme should have correct app bar theme', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.lightTheme;
      expect(theme.appBarTheme.backgroundColor, AppColors.matisse600);
      expect(theme.appBarTheme.foregroundColor, Colors.white);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, isTrue);
    });

    testWidgets('darkTheme should have correct brightness', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('darkTheme should use Material 3', (WidgetTester tester) async {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('darkTheme should have correct primary color', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.darkTheme;
      expect(theme.colorScheme.primary, AppColors.matisse400);
    });

    testWidgets('darkTheme should have correct scaffold background color', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.darkTheme;
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
    });

    testWidgets('darkTheme should have correct card color', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.darkTheme;
      expect(theme.cardColor, AppColors.darkSurface);
    });

    testWidgets('darkTheme should have correct app bar theme', (
      WidgetTester tester,
    ) async {
      final theme = AppTheme.darkTheme;
      expect(theme.appBarTheme.backgroundColor, AppColors.matisse900);
      expect(theme.appBarTheme.foregroundColor, Colors.white);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, isTrue);
    });

    testWidgets('lightTheme and darkTheme should have different brightness', (
      WidgetTester tester,
    ) async {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;
      expect(lightTheme.brightness, isNot(darkTheme.brightness));
    });
  });
}
