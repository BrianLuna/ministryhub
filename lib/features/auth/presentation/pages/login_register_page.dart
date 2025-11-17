import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ministryhub/l10n/app_localizations.dart';

/// Login and Register page
/// Displays the unified auth surface for both sign in and sign out flows.
class LoginRegisterPage extends StatelessWidget {
  const LoginRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final logoColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

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
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: l10n.emailFieldLabel,
                          hintText: l10n.emailFieldHint,
                          prefixIcon: const Icon(
                            Icons.alternate_email_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: l10n.passwordFieldLabel,
                          hintText: l10n.passwordFieldHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(l10n.primaryAuthButton),
                      ),
                      const SizedBox(height: 20),
                      divider,
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/google.svg',
                          height: 20,
                          width: 20,
                          semanticsLabel: l10n.googleAuthButton,
                        ),
                        label: Text(l10n.googleAuthButton),
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
