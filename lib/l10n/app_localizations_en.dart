// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MinistryHub';

  @override
  String get loginRegisterTitle => 'Login / Register';

  @override
  String get welcome => 'Welcome';

  @override
  String get loginRegisterFormPlaceholder => 'Login/Register form';

  @override
  String get authSubtitle => 'Ministry administration, modernized';

  @override
  String get authDescription =>
      'Coordinate campuses, teams, and resources from a single hub designed for scale.';

  @override
  String get emailFieldLabel => 'Email address';

  @override
  String get emailFieldHint => 'name@ministry.org';

  @override
  String get passwordFieldLabel => 'Password';

  @override
  String get passwordFieldHint => 'Enter your password';

  @override
  String get primaryAuthButton => 'Enter MinistryHub';

  @override
  String get googleAuthButton => 'Continue with Google';

  @override
  String get dividerLabel => 'or continue with';

  @override
  String get authFooterHint =>
      'If the email is new, we will guide you to create an account.';
}
