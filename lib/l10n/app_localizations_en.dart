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
  String get confirmPasswordFieldLabel => 'Confirm password';

  @override
  String get confirmPasswordFieldHint => 'Re-enter your password';

  @override
  String get primaryAuthButton => 'Enter MinistryHub';

  @override
  String get authModeLoginLabel => 'Login';

  @override
  String get authModeRegisterLabel => 'Register';

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
  String get confirmPasswordRequiredError => 'Please confirm your password.';

  @override
  String get confirmPasswordMismatchError => 'Passwords do not match.';

  @override
  String get authErrorInvalidEmail => 'The email address is invalid.';

  @override
  String get authErrorWrongPassword =>
      'The password does not match this account.';

  @override
  String get authErrorInvalidCredentials =>
      'Error in the entered data. Please check your email and password.';

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

  @override
  String get continueButtonLabel => 'Continue';

  @override
  String get accountNotFoundLabel =>
      'We couldn\'t find an account with that email.';

  @override
  String get accountNotFoundAction => 'Create account';

  @override
  String get registerDialogTitle => 'Create MinistryHub account';

  @override
  String get registerDialogSubtitle =>
      'Complete the information below to create your access.';

  @override
  String get registerFirstNameLabel => 'First name';

  @override
  String get registerLastNameLabel => 'Last name';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPrimaryButton => 'Create account';

  @override
  String get registerCancelButton => 'Cancel';

  @override
  String get firstNameRequiredError => 'Please enter your first name.';

  @override
  String get lastNameRequiredError => 'Please enter your last name.';

  @override
  String get forgotPasswordButton => 'Forgot password?';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent. Check your inbox.';

  @override
  String get settingsTitle => 'Account Settings';

  @override
  String get settingsProfileSection => 'Profile';

  @override
  String get settingsThemeSection => 'Theme';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsFirstNameLabel => 'First name';

  @override
  String get settingsLastNameLabel => 'Last name';

  @override
  String get settingsEmailLabel => 'Email';

  @override
  String get settingsPhotoLabel => 'Profile photo';

  @override
  String get settingsChangePhoto => 'Change photo';

  @override
  String get settingsTakePhoto => 'Take photo';

  @override
  String get settingsSelectPhoto => 'Select photo';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsManageGoogleAccount => 'Manage my Google account';

  @override
  String get settingsSaveButton => 'Save changes';

  @override
  String get settingsCancelButton => 'Cancel';

  @override
  String get settingsDeleteAccountButton => 'Delete account';

  @override
  String get settingsDeleteAccountTitle => 'Delete account';

  @override
  String get settingsDeleteAccountMessage =>
      'Are you sure you want to delete your account? This action cannot be undone and all your data will be deleted.';

  @override
  String get settingsDeleteAccountConfirm => 'Delete';

  @override
  String get settingsDeleteAccountCancel => 'Cancel';

  @override
  String get settingsProfileUpdated => 'Profile updated successfully';

  @override
  String get settingsProfileUpdateError => 'Error updating profile';

  @override
  String get settingsAccountDeleted => 'Account deleted successfully';

  @override
  String get settingsAccountDeleteError => 'Error deleting account';

  @override
  String get settingsPhotoUploadError => 'Error uploading photo';

  @override
  String get settingsPhotoSelectionCancelled => 'Photo selection cancelled';

  @override
  String get settingsCannotOpenUrl =>
      'Cannot open URL. Please visit https://myaccount.google.com manually.';

  @override
  String get settingsGoogleDisplayNameHint =>
      'Display name from Google account';

  @override
  String get settingsPreferredMinistrySection => 'Preferred Ministry';

  @override
  String get settingsPreferredMinistryLabel => 'Preferred Ministry';

  @override
  String get settingsPreferredMinistryHint => 'Select your preferred ministry';

  @override
  String get settingsNoMinistriesAvailable =>
      'No ministries available. Create a ministry to set a preferred one.';

  @override
  String get settingsDeleteAccountAdministratorRestriction =>
      'You cannot delete your account while you are an administrator of a ministry. Please transfer administration rights to another user first.';

  @override
  String get ministryCreateTitle => 'Create Ministry';

  @override
  String get ministryNameLabel => 'Ministry Name';

  @override
  String get ministryNameHint => 'Enter ministry name';

  @override
  String get ministryNameRequired => 'Ministry name is required';

  @override
  String get ministryNameTooShort =>
      'Ministry name must be at least 2 characters';

  @override
  String get ministryCancel => 'Cancel';

  @override
  String get ministryCreate => 'Create';

  @override
  String get ministrySelectMinistry => 'Select Ministry';

  @override
  String get ministryNoMinistries => 'No ministries available';

  @override
  String get ministrySettings => 'Ministry Settings';

  @override
  String get ministrySettingsTitle => 'Ministry Settings';

  @override
  String get ministryLogoLabel => 'Logo';

  @override
  String get ministryLogoSourceTitle => 'Select Logo Source';

  @override
  String get ministryLogoSourceGallery => 'Gallery';

  @override
  String get ministryLogoSourceCamera => 'Camera';

  @override
  String get ministrySave => 'Save';

  @override
  String get ministryUpdateSuccess => 'Ministry updated successfully';

  @override
  String get ministryUpdateError => 'Error updating ministry';

  @override
  String get ministryLogoUploadError => 'Error uploading logo';

  @override
  String get ministryDeleteButton => 'Delete Ministry';

  @override
  String get ministryDeleteTitle => 'Delete Ministry';

  @override
  String get ministryDeleteMessage =>
      'Are you sure you want to delete this ministry? This action cannot be undone and all ministry data will be deleted.';

  @override
  String get ministryDeleteConfirm => 'Delete';

  @override
  String get ministryDeleteCancel => 'Cancel';

  @override
  String get ministryDeleteSuccess => 'Ministry deleted successfully';

  @override
  String get ministryDeleteError => 'Error deleting ministry';
}
