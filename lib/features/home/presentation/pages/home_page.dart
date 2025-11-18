import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ministryhub/ministryhub.dart';

/// Simple scaffold that hosts the first authenticated surface.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foregroundColor =
        theme.appBarTheme.foregroundColor ?? colorScheme.onSurface;
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        centerTitle: false,
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? colorScheme.surface,
        elevation: 0,
        titleSpacing: 16,
        title: SvgPicture.asset(
          'assets/logotype.svg',
          height: 26,
          colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<_HomeMenuAction>(
              tooltip: l10n.homeProfileMenuLabel,
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              onSelected: (action) async {
                switch (action) {
                  case _HomeMenuAction.settings:
                    // TODO(brian): Navigate to user settings when implemented.
                    break;
                  case _HomeMenuAction.signOut:
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      context.goNamed('login');
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<_HomeMenuAction>(
                  value: _HomeMenuAction.settings,
                  height: 40,
                  child: _MenuRow(
                    icon: Icons.manage_accounts_outlined,
                    label: l10n.homeProfileMenuSettings,
                  ),
                ),
                PopupMenuItem<_HomeMenuAction>(
                  value: _HomeMenuAction.signOut,
                  height: 40,
                  child: _MenuRow(
                    icon: Icons.logout_rounded,
                    label: l10n.homeProfileMenuSignOut,
                  ),
                ),
              ],
              child: _ProfileAvatar(
                user: user,
                foregroundColor: colorScheme.onSurface,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
      body: const SizedBox.shrink(),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final iconColor = theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Text(label, style: textStyle),
      ],
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar({
    required this.user,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final AuthUser? user;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.user?.photoUrl;
    final shouldShowImage =
        photoUrl != null && photoUrl.isNotEmpty && !_hasError;

    return CircleAvatar(
      radius: 17,
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      backgroundImage: shouldShowImage ? NetworkImage(photoUrl) : null,
      onBackgroundImageError: shouldShowImage
          ? (exception, stackTrace) {
              if (mounted) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _hasError = true;
                    });
                  }
                });
              }
            }
          : null,
      child: !shouldShowImage
          ? Text(
              _initials,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            )
          : null,
    );
  }

  String get _initials {
    final source = widget.user?.displayName?.trim();
    if (source != null && source.isNotEmpty) {
      final parts = source
          .split(' ')
          .where((value) => value.isNotEmpty)
          .toList();
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    final email = widget.user?.email;
    if (email != null && email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    return '?';
  }
}

enum _HomeMenuAction { settings, signOut }
