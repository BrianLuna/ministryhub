// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MinistryHub';

  @override
  String get loginRegisterTitle => 'Inicio de Sesión / Registro';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get loginRegisterFormPlaceholder =>
      'Formulario de inicio de sesión/registro';

  @override
  String get authSubtitle => 'Administración ministerial, modernizada';

  @override
  String get authDescription =>
      'Coordina campus, equipos y recursos desde un solo hub pensado para escalar.';

  @override
  String get emailFieldLabel => 'Correo electrónico';

  @override
  String get emailFieldHint => 'nombre@ministerio.org';

  @override
  String get passwordFieldLabel => 'Contraseña';

  @override
  String get passwordFieldHint => 'Ingresa tu contraseña';

  @override
  String get primaryAuthButton => 'Entrar a MinistryHub';

  @override
  String get googleAuthButton => 'Continuar con Google';

  @override
  String get dividerLabel => 'o';

  @override
  String get authFooterHint =>
      'Si el correo es nuevo, te guiaremos para crear una cuenta.';

  @override
  String get emailRequiredError => 'Ingresa tu correo electrónico.';

  @override
  String get invalidEmailFormatError => 'Ingresa un correo válido.';

  @override
  String get passwordRequiredError => 'Ingresa tu contraseña.';

  @override
  String get passwordLengthError =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get authErrorInvalidEmail => 'El correo electrónico es inválido.';

  @override
  String get authErrorWrongPassword =>
      'La contraseña no coincide con esta cuenta.';

  @override
  String get authErrorUserDisabled =>
      'Esta cuenta fue deshabilitada. Contacta a tu administrador.';

  @override
  String get authErrorCredentialConflict =>
      'Este correo ya está vinculado a otro proveedor.';

  @override
  String get authErrorGoogleCancelled => 'Se canceló el acceso con Google.';

  @override
  String get authErrorGeneric =>
      'No pudimos completar la acción. Intenta nuevamente.';

  @override
  String get homeProfileMenuLabel => 'Opciones de cuenta';

  @override
  String get homeProfileMenuSignOut => 'Cerrar sesión';

  @override
  String get homeProfileMenuSettings => 'Configuración de cuenta';
}
