import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ministryhub/ministryhub.dart';

/// Login and Register page
/// Displays the unified auth surface for both sign in and sign out flows.
enum _AuthMode { login, register }

class LoginRegisterPage extends ConsumerStatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  ConsumerState<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends ConsumerState<LoginRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _confirmPasswordController;
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _autoValidate = false;
  bool _obscurePassword = true;
  bool _isPrimaryActionLoading = false;
  bool _isGoogleLoading = false;
  _AuthMode _authMode = _AuthMode.login;
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _authSubscription = ref.listenManual<AuthState>(
      authControllerProvider,
      _handleAuthStateUpdates,
    );
    // Check if user is already authenticated and redirect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      if (authState.status == AuthStatus.authenticated && mounted) {
        context.goNamed('home');
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.close();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _handleAuthStateUpdates(AuthState? previous, AuthState next) {
    if (!mounted) {
      return;
    }
    // Reset loading states when status changes
    if (next.status != AuthStatus.loading) {
      if (_isPrimaryActionLoading || _isGoogleLoading) {
        setState(() {
          _isPrimaryActionLoading = false;
          _isGoogleLoading = false;
        });
      }
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
    if (next.showRegistrationPrompt &&
        previous?.showRegistrationPrompt != next.showRegistrationPrompt) {
      final l10n = AppLocalizations.of(context)!;
      if (_authMode != _AuthMode.register) {
        setState(() {
          _authMode = _AuthMode.register;
        });
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.accountNotFoundLabel)));
      ref.read(authControllerProvider.notifier).clearRegistrationPrompt();
    }
  }

  void _onPrimaryAction(AppLocalizations l10n) {
    if (!_autoValidate) {
      setState(() {
        _autoValidate = true;
      });
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isPrimaryActionLoading = true;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final notifier = ref.read(authControllerProvider.notifier);
    if (_authMode == _AuthMode.login) {
      notifier.signInWithEmail(email: email, password: password);
    } else {
      notifier.registerWithEmail(
        email: email,
        password: password,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
    }
  }

  void _onGoogleSignIn() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isGoogleLoading = true;
    });
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

  String? _validateConfirmPassword(String? value, AppLocalizations l10n) {
    if (_authMode != _AuthMode.register) {
      return null;
    }
    if (value == null || value.trim().isEmpty) {
      return l10n.confirmPasswordRequiredError;
    }
    if (value.trim() != _passwordController.text.trim()) {
      return l10n.confirmPasswordMismatchError;
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

            final isRegisterMode = _authMode == _AuthMode.register;

            final formFields = Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<_AuthMode>(
                    segments: [
                      ButtonSegment<_AuthMode>(
                        value: _AuthMode.login,
                        label: Text(l10n.authModeLoginLabel),
                        icon: const Icon(Icons.login_rounded),
                      ),
                      ButtonSegment<_AuthMode>(
                        value: _AuthMode.register,
                        label: Text(l10n.authModeRegisterLabel),
                        icon: const Icon(Icons.badge_outlined),
                      ),
                    ],
                    selected: {_authMode},
                    onSelectionChanged: isLoading
                        ? null
                        : (selection) {
                            final mode = selection.first;
                            if (mode == _authMode) {
                              return;
                            }
                            setState(() {
                              _authMode = mode;
                            });
                          },
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: child,
                        ),
                      );
                    },
                    child: isRegisterMode
                        ? FadeInDown(
                            key: const ValueKey('registerSection'),
                            duration: const Duration(milliseconds: 600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l10n.registerDialogSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _firstNameController,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.givenName,
                                        ],
                                        decoration: InputDecoration(
                                          labelText:
                                              l10n.registerFirstNameLabel,
                                          prefixIcon: const Icon(
                                            Icons.badge_outlined,
                                          ),
                                        ),
                                        validator: (value) =>
                                            _authMode != _AuthMode.register
                                            ? null
                                            : _validateName(
                                                value,
                                                l10n.firstNameRequiredError,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _lastNameController,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.familyName,
                                        ],
                                        decoration: InputDecoration(
                                          labelText: l10n.registerLastNameLabel,
                                          prefixIcon: const Icon(Icons.badge),
                                        ),
                                        validator: (value) =>
                                            _authMode != _AuthMode.register
                                            ? null
                                            : _validateName(
                                                value,
                                                l10n.lastNameRequiredError,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('registerSectionPlaceholder'),
                          ),
                  ),
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
                    textInputAction: isRegisterMode
                        ? TextInputAction.next
                        : TextInputAction.done,
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
                    onChanged: (_) {
                      if (isRegisterMode && _autoValidate) {
                        _formKey.currentState?.validate();
                      }
                    },
                    onFieldSubmitted: (_) {
                      if (isRegisterMode) {
                        _confirmPasswordFocusNode.requestFocus();
                      } else {
                        _onPrimaryAction(l10n);
                      }
                    },
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: child,
                        ),
                      );
                    },
                    child: isRegisterMode
                        ? FadeInUp(
                            key: const ValueKey('confirmPasswordField'),
                            duration: const Duration(milliseconds: 600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmPasswordFocusNode,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: l10n.confirmPasswordFieldLabel,
                                    hintText: l10n.confirmPasswordFieldHint,
                                    prefixIcon: const Icon(Icons.lock_reset),
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
                                  validator: (value) =>
                                      _validateConfirmPassword(value, l10n),
                                  onFieldSubmitted: (_) =>
                                      _onPrimaryAction(l10n),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('confirmPasswordPlaceholder'),
                          ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: child,
                        ),
                      );
                    },
                    child: isRegisterMode
                        ? const SizedBox.shrink(
                            key: ValueKey('forgotPasswordPlaceholder'),
                          )
                        : FadeInRight(
                            key: const ValueKey('forgotPasswordButton'),
                            duration: const Duration(milliseconds: 600),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _onForgotPassword(l10n),
                                child: Text(l10n.forgotPasswordButton),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: isLoading ? null : () => _onPrimaryAction(l10n),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: _isPrimaryActionLoading
                        ? _buildProgressIndicator(colorScheme.onPrimary)
                        : Text(
                            isRegisterMode
                                ? l10n.registerPrimaryButton
                                : l10n.primaryAuthButton,
                          ),
                  ),
                ],
              ),
            );

            final cardContent = Card(
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
                    formFields,
                    const SizedBox(height: 8),
                    divider,
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : _onGoogleSignIn,
                      icon: _isGoogleLoading
                          ? _buildProgressIndicator(colorScheme.primary)
                          : SvgPicture.asset(
                              'assets/google.svg',
                              height: 20,
                              width: 20,
                              semanticsLabel: l10n.googleAuthButton,
                            ),
                      label: _isGoogleLoading
                          ? const SizedBox.shrink()
                          : Text(l10n.googleAuthButton),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );

            final formCard = FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                child: cardContent,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      heroSection,
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: cardWidth,
                            maxWidth: cardWidth,
                          ),
                          child: formCard,
                        ),
                      ),
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
