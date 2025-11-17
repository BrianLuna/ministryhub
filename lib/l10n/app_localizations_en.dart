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
  String get dividerLabel => 'or';

  @override
  String get authFooterHint =>
      'If the email is new, we will guide you to create an account.';

  @override
  String get emailRequiredError => 'Please enter your email.';

  @override
  String get invalidEmailFormatError => 'Enter a valid email address.';

  @override
  String get passwordRequiredError => 'Please enter your password.';

  @override
  String get passwordLengthError => 'Password must be at least 8 characters.';

  @override
  String get authErrorInvalidEmail => 'The email address is invalid.';

  @override
  String get authErrorWrongPassword =>
      'The password does not match this account.';

  @override
  String get authErrorUserDisabled =>
      'This account has been disabled. Contact your administrator.';

  @override
  String get authErrorCredentialConflict =>
      'This email is already linked to another provider.';

  @override
  String get authErrorGoogleCancelled => 'Google sign-in was cancelled.';

  @override
  String get authErrorGeneric =>
      'We couldn\'t complete the action. Please try again.';

  @override
  String get homeProfileMenuLabel => 'Account options';

  @override
  String get homeProfileMenuSignOut => 'Sign out';

  @override
  String get homeProfileMenuSettings => 'Account settings';
}
