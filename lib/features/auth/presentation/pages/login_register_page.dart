import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ministryhub/ministryhub.dart';

/// Login and Register page
/// Displays the unified auth surface for both sign in and sign out flows.
class LoginRegisterPage extends ConsumerStatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  ConsumerState<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends ConsumerState<LoginRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final FocusNode _passwordFocusNode = FocusNode();
  bool _autoValidate = false;
  bool _obscurePassword = true;
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _authSubscription = ref.listenManual<AuthState>(
      authControllerProvider,
      _handleAuthStateUpdates,
    );
  }

  @override
  void dispose() {
    _authSubscription?.close();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleAuthStateUpdates(AuthState? previous, AuthState next) {
    if (!mounted) {
      return;
    }
    if (next.status == AuthStatus.authenticated &&
        previous?.status != AuthStatus.authenticated) {
      context.goNamed('home');
      return;
    }
    if (next.errorCode != null && next.errorCode != previous?.errorCode) {
      final l10n = AppLocalizations.of(context)!;
      final message = _mapAuthErrorToMessage(next.errorCode!, l10n);
      if (message != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
      ref.read(authControllerProvider.notifier).clearError();
    }
  }

  void _onSubmit(AppLocalizations l10n) {
    if (!_autoValidate) {
      setState(() {
        _autoValidate = true;
      });
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    ref
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: email, password: password);
  }

  void _onGoogleSignIn() {
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  Future<void> _onForgotPassword(AppLocalizations l10n) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.emailRequiredError)));
      return;
    }
    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.invalidEmailFormatError)));
      return;
    }
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.passwordResetEmailSent)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.authErrorGeneric)));
    }
  }

  Future<void> _onOpenRegistrationDialog(AppLocalizations l10n) async {
    final email = _emailController.text.trim();
    final result = await _showRegistrationDialog(email: email, l10n: l10n);
    if (result == null || !mounted) return;
    ref
        .read(authControllerProvider.notifier)
        .registerWithEmail(
          email: email,
          password: result.password,
          firstName: result.firstName,
          lastName: result.lastName,
        );
  }

  Future<_RegistrationFormData?> _showRegistrationDialog({
    required String email,
    required AppLocalizations l10n,
  }) async {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final passwordController = TextEditingController();
    var autoValidateDialog = false;
    final disposables = <VoidCallback>[];
    try {
      final result = await showDialog<_RegistrationFormData>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(l10n.registerDialogTitle),
                content: Form(
                  key: formKey,
                  autovalidateMode: autoValidateDialog
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.registerDialogSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: l10n.registerFirstNameLabel,
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) =>
                              _validateName(value, l10n.firstNameRequiredError),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelText: l10n.registerLastNameLabel,
                            prefixIcon: const Icon(Icons.badge),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) =>
                              _validateName(value, l10n.lastNameRequiredError),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: email,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: l10n.registerEmailLabel,
                            prefixIcon: const Icon(Icons.alternate_email),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.passwordFieldLabel,
                            hintText: l10n.passwordFieldHint,
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          validator: (value) => _validatePassword(value, l10n),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.registerCancelButton),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (!autoValidateDialog) {
                        setDialogState(() {
                          autoValidateDialog = true;
                        });
                      }
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      Navigator.of(dialogContext).pop(
                        _RegistrationFormData(
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          password: passwordController.text.trim(),
                        ),
                      );
                    },
                    child: Text(l10n.registerPrimaryButton),
                  ),
                ],
              );
            },
          );
        },
      );
      disposables.addAll([
        () => firstNameController.dispose(),
        () => lastNameController.dispose(),
        () => passwordController.dispose(),
      ]);
      return result;
    } finally {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final dispose in disposables) {
            dispose();
          }
        });
      } else {
        for (final dispose in disposables) {
          dispose();
        }
      }
    }
  }

  String? _validateName(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.emailRequiredError;
    }
    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.invalidEmailFormatError;
    }
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.passwordRequiredError;
    }
    if (value.trim().length < 8) {
      return l10n.passwordLengthError;
    }
    return null;
  }

  String? _mapAuthErrorToMessage(String code, AppLocalizations l10n) {
    switch (code) {
      case AuthErrorCodes.invalidEmail:
        return l10n.authErrorInvalidEmail;
      case AuthErrorCodes.wrongPassword:
      case AuthErrorCodes.userNotFound:
        return l10n.authErrorInvalidCredentials;
      case AuthErrorCodes.userDisabled:
        return l10n.authErrorUserDisabled;
      case AuthErrorCodes.credentialConflict:
        return l10n.authErrorCredentialConflict;
      case AuthErrorCodes.googleCancelled:
        return l10n.authErrorGoogleCancelled;
      case AuthErrorCodes.generic:
      default:
        return l10n.authErrorGeneric;
    }
  }

  Widget _buildProgressIndicator(Color color) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final logoColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final padding = EdgeInsets.symmetric(
              horizontal: isWide ? 72 : 24,
              vertical: isWide ? 56 : 24,
            );
            final maxWidth = isWide ? 1160.0 : double.infinity;
            final cardWidth = isWide ? 480.0 : double.infinity;
            final dividerColor = colorScheme.outlineVariant.withAlpha(180);

            final logo = Semantics(
              label: l10n.appTitle,
              child: ExcludeSemantics(
                child: SvgPicture.asset(
                  'assets/logotype.svg',
                  height: isWide ? 64 : 48,
                  colorFilter: ColorFilter.mode(logoColor, BlendMode.srcIn),
                ),
              ),
            );

            final heroSection = FadeInDown(
              duration: const Duration(milliseconds: 900),
              child: Column(
                crossAxisAlignment: isWide
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: isWide ? Alignment.centerLeft : Alignment.center,
                    child: logo,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.authSubtitle,
                    textAlign: isWide ? TextAlign.start : TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 460 : double.infinity,
                    ),
                    child: Text(
                      l10n.authDescription,
                      textAlign: isWide ? TextAlign.start : TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );

            final divider = Row(
              children: [
                Expanded(child: Divider(color: dividerColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    l10n.dividerLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: dividerColor)),
              ],
            );

            final formFields = Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: l10n.emailFieldLabel,
                      hintText: l10n.emailFieldHint,
                      prefixIcon: const Icon(Icons.alternate_email_outlined),
                    ),
                    validator: (value) => _validateEmail(value, l10n),
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: l10n.passwordFieldLabel,
                      hintText: l10n.passwordFieldHint,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) => _validatePassword(value, l10n),
                    onFieldSubmitted: (_) => _onSubmit(l10n),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => _onForgotPassword(l10n),
                      child: Text(l10n.forgotPasswordButton),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: isLoading ? null : () => _onSubmit(l10n),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: isLoading
                        ? _buildProgressIndicator(colorScheme.onPrimary)
                        : Text(l10n.primaryAuthButton),
                  ),
                  if (authState.showRegistrationPrompt) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.accountNotFoundLabel,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => _onOpenRegistrationDialog(l10n),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n.accountNotFoundAction),
                    ),
                  ],
                ],
              ),
            );

            final formCard = FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: Card(
                elevation: 8,
                shadowColor: colorScheme.shadow.withAlpha(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: colorScheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.loginRegisterTitle,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authFooterHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      formFields,
                      const SizedBox(height: 8),
                      divider,
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _onGoogleSignIn,
                        icon: SvgPicture.asset(
                          'assets/google.svg',
                          height: 20,
                          width: 20,
                          semanticsLabel: l10n.googleAuthButton,
                        ),
                        label: isLoading
                            ? _buildProgressIndicator(colorScheme.primary)
                            : Text(l10n.googleAuthButton),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            final content = isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: heroSection),
                      const SizedBox(width: 48),
                      formCard,
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      heroSection,
                      const SizedBox(height: 32),
                      formCard,
                    ],
                  );

            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withAlpha(120),
                    colorScheme.secondaryContainer.withAlpha(160),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    padding: padding,
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegistrationFormData {
  const _RegistrationFormData({
    required this.firstName,
    required this.lastName,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String password;
}
