import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'MinistryHub'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Placeholder text for login/register form
  ///
  /// In en, this message translates to:
  /// **'Login/Register form'**
  String get loginRegisterFormPlaceholder;

  /// Short subtitle for the auth hero section
  ///
  /// In en, this message translates to:
  /// **'Ministry administration, modernized'**
  String get authSubtitle;

  /// Supportive description for the hero section
  ///
  /// In en, this message translates to:
  /// **'Coordinate campuses, teams, and resources from a single hub designed for scale.'**
  String get authDescription;

  /// Label for the email text field
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailFieldLabel;

  /// Hint text for the email field
  ///
  /// In en, this message translates to:
  /// **'name@ministry.org'**
  String get emailFieldHint;

  /// Label for the password text field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordFieldLabel;

  /// Hint text for the password field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordFieldHint;

  /// Label for the confirm password text field
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordFieldLabel;

  /// Hint text for the confirm password field
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordFieldHint;

  /// Label for the main auth button
  ///
  /// In en, this message translates to:
  /// **'Enter MinistryHub'**
  String get primaryAuthButton;

  /// Label for the login toggle segment
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authModeLoginLabel;

  /// Label for the register toggle segment
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authModeRegisterLabel;

  /// Label for the Google auth button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleAuthButton;

  /// Text shown between dividers
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get dividerLabel;

  /// Validation error for empty email field
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get emailRequiredError;

  /// Validation error for invalid email format
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmailFormatError;

  /// Validation error for empty password field
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get passwordRequiredError;

  /// Validation error for short passwords
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordLengthError;

  /// Validation error for missing confirm password
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get confirmPasswordRequiredError;

  /// Validation error when passwords differ
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get confirmPasswordMismatchError;

  /// Shown when Firebase reports invalid email
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get authErrorInvalidEmail;

  /// Shown when user enters wrong password
  ///
  /// In en, this message translates to:
  /// **'The password does not match this account.'**
  String get authErrorWrongPassword;

  /// Shown when authentication fails without revealing if email or password is wrong
  ///
  /// In en, this message translates to:
  /// **'Error in the entered data. Please check your email and password.'**
  String get authErrorInvalidCredentials;

  /// Shown when Firebase reports disabled user
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Contact your administrator.'**
  String get authErrorUserDisabled;

  /// Shown when there is a credential conflict
  ///
  /// In en, this message translates to:
  /// **'This email is already linked to another provider.'**
  String get authErrorCredentialConflict;

  /// Shown when the Google popup is dismissed
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get authErrorGoogleCancelled;

  /// Fallback auth error message
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete the action. Please try again.'**
  String get authErrorGeneric;

  /// Tooltip/label for the profile menu trigger in home
  ///
  /// In en, this message translates to:
  /// **'Account options'**
  String get homeProfileMenuLabel;

  /// Label for the sign out entry in the profile menu
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeProfileMenuSignOut;

  /// Label for the user settings entry in the profile menu
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get homeProfileMenuSettings;

  /// Button label used to continue email verification
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButtonLabel;

  /// Label displayed when no account is associated with an email
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find an account with that email.'**
  String get accountNotFoundLabel;

  /// Button label to open the registration dialog
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get accountNotFoundAction;

  /// Title for the registration dialog
  ///
  /// In en, this message translates to:
  /// **'Create MinistryHub account'**
  String get registerDialogTitle;

  /// Subtitle explaining the registration dialog
  ///
  /// In en, this message translates to:
  /// **'Complete the information below to create your access.'**
  String get registerDialogSubtitle;

  /// Label for the first name field in registration dialog
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get registerFirstNameLabel;

  /// Label for the last name field in registration dialog
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get registerLastNameLabel;

  /// Label for the email field in registration dialog
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// Primary action in the registration dialog
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerPrimaryButton;

  /// Cancel button in the registration dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get registerCancelButton;

  /// Validation error for missing first name
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name.'**
  String get firstNameRequiredError;

  /// Validation error for missing last name
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name.'**
  String get lastNameRequiredError;

  /// Button label to trigger password reset flow
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordButton;

  /// Confirmation message after sending password reset email
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get passwordResetEmailSent;

  /// Title for the account settings overlay
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settingsTitle;

  /// Section title for profile settings
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileSection;

  /// Section title for theme settings
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeSection;

  /// Section title for language settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// Label for first name field in settings
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get settingsFirstNameLabel;

  /// Label for last name field in settings
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get settingsLastNameLabel;

  /// Label for email field in settings
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmailLabel;

  /// Label for profile photo in settings
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get settingsPhotoLabel;

  /// Button label to change profile photo
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get settingsChangePhoto;

  /// Option to take a new photo
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get settingsTakePhoto;

  /// Option to select photo from gallery
  ///
  /// In en, this message translates to:
  /// **'Select photo'**
  String get settingsSelectPhoto;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// System theme option (follows device setting)
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Button label to open Google account management
  ///
  /// In en, this message translates to:
  /// **'Manage my Google account'**
  String get settingsManageGoogleAccount;

  /// Button label to save settings changes
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settingsSaveButton;

  /// Button label to cancel settings changes
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancelButton;

  /// Button label to delete account
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountButton;

  /// Title for delete account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountTitle;

  /// Message in delete account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be deleted.'**
  String get settingsDeleteAccountMessage;

  /// Confirm button in delete account dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteAccountConfirm;

  /// Cancel button in delete account dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsDeleteAccountCancel;

  /// Success message after updating profile
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get settingsProfileUpdated;

  /// Error message when profile update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get settingsProfileUpdateError;

  /// Success message after deleting account
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get settingsAccountDeleted;

  /// Error message when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting account'**
  String get settingsAccountDeleteError;

  /// Error message when photo upload fails
  ///
  /// In en, this message translates to:
  /// **'Error uploading photo'**
  String get settingsPhotoUploadError;

  /// Message when user cancels photo selection
  ///
  /// In en, this message translates to:
  /// **'Photo selection cancelled'**
  String get settingsPhotoSelectionCancelled;

  /// Error message when URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Cannot open URL. Please visit https://myaccount.google.com manually.'**
  String get settingsCannotOpenUrl;

  /// Helper text for Google account display name field
  ///
  /// In en, this message translates to:
  /// **'Display name from Google account'**
  String get settingsGoogleDisplayNameHint;

  /// Title for preferred ministry section in account settings
  ///
  /// In en, this message translates to:
  /// **'Preferred Ministry'**
  String get settingsPreferredMinistrySection;

  /// Label for preferred ministry dropdown
  ///
  /// In en, this message translates to:
  /// **'Preferred Ministry'**
  String get settingsPreferredMinistryLabel;

  /// Hint text for preferred ministry dropdown
  ///
  /// In en, this message translates to:
  /// **'Select your preferred ministry'**
  String get settingsPreferredMinistryHint;

  /// Message shown when no ministries are available
  ///
  /// In en, this message translates to:
  /// **'No ministries available. Create a ministry to set a preferred one.'**
  String get settingsNoMinistriesAvailable;

  /// Tooltip message explaining why account deletion is disabled for administrators
  ///
  /// In en, this message translates to:
  /// **'You cannot delete your account while you are an administrator of a ministry. Please transfer administration rights to another user first.'**
  String get settingsDeleteAccountAdministratorRestriction;

  /// Title for create ministry dialog
  ///
  /// In en, this message translates to:
  /// **'Create Ministry'**
  String get ministryCreateTitle;

  /// Label for ministry name field
  ///
  /// In en, this message translates to:
  /// **'Ministry Name'**
  String get ministryNameLabel;

  /// Hint text for ministry name field
  ///
  /// In en, this message translates to:
  /// **'Enter ministry name'**
  String get ministryNameHint;

  /// Error message when ministry name is empty
  ///
  /// In en, this message translates to:
  /// **'Ministry name is required'**
  String get ministryNameRequired;

  /// Error message when ministry name is too short
  ///
  /// In en, this message translates to:
  /// **'Ministry name must be at least 2 characters'**
  String get ministryNameTooShort;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ministryCancel;

  /// Create button label
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get ministryCreate;

  /// Placeholder text for ministry selector when no ministry is selected
  ///
  /// In en, this message translates to:
  /// **'Select Ministry'**
  String get ministrySelectMinistry;

  /// Message shown when user has no ministries
  ///
  /// In en, this message translates to:
  /// **'No ministries available'**
  String get ministryNoMinistries;

  /// Tooltip for ministry settings button
  ///
  /// In en, this message translates to:
  /// **'Ministry Settings'**
  String get ministrySettings;

  /// Title for ministry settings overlay
  ///
  /// In en, this message translates to:
  /// **'Ministry Settings'**
  String get ministrySettingsTitle;

  /// Label for ministry logo section
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get ministryLogoLabel;

  /// Title for logo source selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Logo Source'**
  String get ministryLogoSourceTitle;

  /// Option to select logo from gallery
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get ministryLogoSourceGallery;

  /// Option to take logo photo with camera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get ministryLogoSourceCamera;

  /// Save button label in ministry settings
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get ministrySave;

  /// Success message after updating ministry
  ///
  /// In en, this message translates to:
  /// **'Ministry updated successfully'**
  String get ministryUpdateSuccess;

  /// Error message when ministry update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating ministry'**
  String get ministryUpdateError;

  /// Error message when logo upload fails
  ///
  /// In en, this message translates to:
  /// **'Error uploading logo'**
  String get ministryLogoUploadError;

  /// Button label to delete ministry
  ///
  /// In en, this message translates to:
  /// **'Delete Ministry'**
  String get ministryDeleteButton;

  /// Title for delete ministry confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Ministry'**
  String get ministryDeleteTitle;

  /// Message in delete ministry confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ministry? This action cannot be undone and all ministry data will be deleted.'**
  String get ministryDeleteMessage;

  /// Confirm button in delete ministry dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get ministryDeleteConfirm;

  /// Cancel button in delete ministry dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ministryDeleteCancel;

  /// Success message after deleting ministry
  ///
  /// In en, this message translates to:
  /// **'Ministry deleted successfully'**
  String get ministryDeleteSuccess;

  /// Error message when ministry deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting ministry'**
  String get ministryDeleteError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
