import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ministryhub/ministryhub.dart';

/// Account settings overlay shown as a bottom sheet
class AccountSettingsOverlay extends ConsumerStatefulWidget {
  const AccountSettingsOverlay({super.key});

  @override
  ConsumerState<AccountSettingsOverlay> createState() =>
      _AccountSettingsOverlayState();

  /// Show the overlay as a bottom sheet
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccountSettingsOverlay(),
    );
  }
}

class _AccountSettingsOverlayState
    extends ConsumerState<AccountSettingsOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      final uid = authState.user?.uid;
      final displayName = authState.user?.displayName;
      if (uid != null) {
        ref
            .read(settingsControllerProvider.notifier)
            .loadProfile(uid, displayName: displayName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final settingsState = ref.watch(settingsControllerProvider);

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(77),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Text(l10n.settingsTitle, style: theme.textTheme.headlineSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Section
                  _ProfileSection(user: user, settingsState: settingsState),
                  const SizedBox(height: 24),
                  // Theme Section
                  _ThemeSection(),
                  const SizedBox(height: 24),
                  // Language Section
                  _LanguageSection(),
                  const SizedBox(height: 24),
                  // Preferred Entity Section
                  _PreferredEntitySection(),
                  const SizedBox(height: 24),
                  // Delete Account Button
                  _DeleteAccountSection(user: user),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile section widget
class _ProfileSection extends ConsumerStatefulWidget {
  const _ProfileSection({required this.user, required this.settingsState});

  final AuthUser user;
  final SettingsState settingsState;

  @override
  ConsumerState<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<_ProfileSection> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _controllersInitialized = false;
  bool _hasImageError = false;
  String? _lastPhotoUrl;

  @override
  void initState() {
    super.initState();
    _lastPhotoUrl = widget.user.photoUrl;
    _initializeControllers();
  }

  @override
  void didUpdateWidget(_ProfileSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controllers if profile was loaded from server
    // Don't update if user is currently editing (to avoid text selection)
    if (!_controllersInitialized &&
        oldWidget.settingsState.profile != widget.settingsState.profile) {
      _initializeControllers();
    }
    // Reset image error if photo URL changed
    final currentPhotoUrl = widget.user.photoUrl;
    if (_lastPhotoUrl != currentPhotoUrl) {
      _lastPhotoUrl = currentPhotoUrl;
      if (_hasImageError) {
        setState(() {
          _hasImageError = false;
        });
      }
    }
    // Reset image error if a new local image was selected
    if (oldWidget.settingsState.selectedImagePath !=
        widget.settingsState.selectedImagePath) {
      if (_hasImageError) {
        setState(() {
          _hasImageError = false;
        });
      }
    }
  }

  void _initializeControllers() {
    if (_controllersInitialized) return;

    final firstName = widget.settingsState.firstName.isNotEmpty
        ? widget.settingsState.firstName
        : widget.user.displayName?.split(' ').first ?? '';
    final lastName = widget.settingsState.lastName.isNotEmpty
        ? widget.settingsState.lastName
        : widget.user.displayName?.split(' ').skip(1).join(' ') ?? '';

    // Only set if different to avoid cursor jumping
    if (_firstNameController.text != firstName) {
      _firstNameController.text = firstName;
    }
    if (_lastNameController.text != lastName) {
      _lastNameController.text = lastName;
    }

    _controllersInitialized = true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isGoogleUser = widget.user.isGoogleUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settingsProfileSection, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        // Photo
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: _getPhotoImage(),
                onBackgroundImageError: _getPhotoImage() != null
                    ? (exception, stackTrace) {
                        if (mounted) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _hasImageError = true;
                              });
                            }
                          });
                        }
                      }
                    : null,
                child: _getPhotoImage() == null
                    ? Text(
                        _getInitials(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              if (!isGoogleUser)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildCameraButton(theme),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Name fields (only editable for email users)
        if (!isGoogleUser) ...[
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: l10n.settingsFirstNameLabel),
            onChanged: (value) => ref
                .read(settingsControllerProvider.notifier)
                .updateFirstName(value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: l10n.settingsLastNameLabel),
            onChanged: (value) => ref
                .read(settingsControllerProvider.notifier)
                .updateLastName(value),
          ),
          const SizedBox(height: 16),
        ] else ...[
          // Display name for Google users (read-only)
          TextField(
            controller: TextEditingController(
              text: widget.user.displayName ?? '',
            ),
            decoration: InputDecoration(
              labelText: l10n.settingsProfileSection,
              helperText: l10n.settingsGoogleDisplayNameHint,
            ),
            enabled: false,
          ),
          const SizedBox(height: 16),
        ],
        // Email (read-only)
        TextField(
          controller: TextEditingController(text: widget.user.email ?? ''),
          decoration: InputDecoration(labelText: l10n.settingsEmailLabel),
          enabled: false,
        ),
        // Google Account button
        if (isGoogleUser) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openGoogleAccount,
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.settingsManageGoogleAccount),
          ),
        ],
        // Save button (only for email users)
        if (!isGoogleUser) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.settingsState.isSaving
                ? null
                : () => _saveProfile(context),
            child: widget.settingsState.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.settingsSaveButton),
          ),
        ],
      ],
    );
  }

  ImageProvider? _getPhotoImage() {
    final settingsState = widget.settingsState;
    if (settingsState.selectedImagePath != null) {
      return FileImage(File(settingsState.selectedImagePath!));
    }
    if (widget.user.photoUrl != null &&
        widget.user.photoUrl!.isNotEmpty &&
        !_hasImageError) {
      return NetworkImage(widget.user.photoUrl!);
    }
    return null;
  }

  String _getInitials() {
    final displayName = widget.user.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    final email = widget.user.email;
    if (email != null && email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  Widget _buildCameraButton(ThemeData theme) {
    // Make button smaller on Android, keep current size on web
    final isAndroid = !kIsWeb && (Platform.isAndroid);
    final buttonSize = isAndroid ? 32.0 : 48.0;
    final iconSize = isAndroid ? 16.0 : 20.0;
    final borderWidth = isAndroid ? 1.5 : 2.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.scaffoldBackgroundColor,
          width: borderWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showPhotoOptions,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Center(
            child: Icon(
              Icons.camera_alt,
              size: iconSize,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.settingsTakePhoto),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(settingsControllerProvider.notifier)
                    .pickImage(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.settingsSelectPhoto),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(settingsControllerProvider.notifier)
                    .pickImage(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final uid = widget.user.uid;

    final success = await ref
        .read(settingsControllerProvider.notifier)
        .saveProfile(uid);

    if (!mounted) return;

    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsProfileUpdated)),
      );
      // Reload auth state to get updated user
      final authState = ref.read(authControllerProvider);
      if (authState.user != null) {
        // The auth state will update automatically via stream
      }
    } else {
      final error = ref.read(settingsControllerProvider).error;
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(error ?? l10n.settingsProfileUpdateError),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _openGoogleAccount() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final url = Uri.parse('https://myaccount.google.com/personal-info');

      // Try to launch directly - canLaunchUrl can fail if plugin isn't ready
      // but launchUrl will still work in most cases
      try {
        final canLaunch = await canLaunchUrl(url).timeout(
          const Duration(seconds: 2),
          onTimeout: () => true, // Assume we can launch if timeout
        );
        if (!canLaunch) {
          throw Exception('Cannot launch URL');
        }
      } catch (e) {
        // If canLaunchUrl fails, try to launch anyway
        debugPrint('canLaunchUrl check failed, attempting launch anyway: $e');
      }

      // Launch the URL
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // If url_launcher is not available, show a message to the user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsCannotOpenUrl)));
      }
      // Log error for debugging
      debugPrint('Error opening Google account URL: $e');
    }
  }
}

/// Theme section widget
class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settingsThemeSection, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(l10n.settingsThemeLight),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(l10n.settingsThemeDark),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.settingsThemeSystem),
            ),
          ],
          selected: {themeMode},
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            themeNotifier.setThemeMode(newSelection.first);
          },
        ),
      ],
    );
  }
}

/// Language section widget
class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settingsLanguageSection, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        SegmentedButton<Locale?>(
          segments: [
            ButtonSegment(
              value: const Locale('es'),
              label: Text(l10n.settingsLanguageSpanish),
            ),
            ButtonSegment(
              value: const Locale('en'),
              label: Text(l10n.settingsLanguageEnglish),
            ),
            ButtonSegment(value: null, label: Text(l10n.settingsThemeSystem)),
          ],
          selected: {locale},
          onSelectionChanged: (Set<Locale?> newSelection) {
            localeNotifier.setLocale(newSelection.first);
          },
        ),
      ],
    );
  }
}

/// Preferred entity section widget
class _PreferredEntitySection extends ConsumerStatefulWidget {
  const _PreferredEntitySection();

  @override
  ConsumerState<_PreferredEntitySection> createState() =>
      _PreferredEntitySectionState();
}

class _PreferredEntitySectionState
    extends ConsumerState<_PreferredEntitySection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      final uid = authState.user?.uid;
      if (uid != null) {
        ref.read(ministryControllerProvider.notifier).loadMinistries(uid);
        ref.read(churchControllerProvider.notifier).loadChurches(uid);
      }
    });
  }

  /// Get a valid preferred entity that exists in the lists
  PreferredEntity? _getValidPreferredEntity(
    PreferredEntity? preferredEntity,
    List<Ministry> ministries,
    List<Church> churches,
  ) {
    if (preferredEntity == null) {
      if (ministries.isNotEmpty) {
        return PreferredEntity(
          id: ministries.first.id,
          type: EntityType.ministry,
        );
      }
      if (churches.isNotEmpty) {
        return PreferredEntity(id: churches.first.id, type: EntityType.church);
      }
      return null;
    }

    // Check if preferred entity exists
    if (preferredEntity.type == EntityType.ministry) {
      final exists = ministries.any((m) => m.id == preferredEntity.id);
      if (exists) {
        return preferredEntity;
      }
      // If preferred ministry doesn't exist, return first available
      return ministries.isNotEmpty
          ? PreferredEntity(id: ministries.first.id, type: EntityType.ministry)
          : (churches.isNotEmpty
                ? PreferredEntity(
                    id: churches.first.id,
                    type: EntityType.church,
                  )
                : null);
    } else {
      final exists = churches.any((c) => c.id == preferredEntity.id);
      if (exists) {
        return preferredEntity;
      }
      // If preferred church doesn't exist, return first available
      return churches.isNotEmpty
          ? PreferredEntity(id: churches.first.id, type: EntityType.church)
          : (ministries.isNotEmpty
                ? PreferredEntity(
                    id: ministries.first.id,
                    type: EntityType.ministry,
                  )
                : null);
    }
  }

  String _getEntityDisplayId(PreferredEntity? entity) {
    if (entity == null) return '';
    return '${entity.type.name}:${entity.id}';
  }

  PreferredEntity? _parseEntityDisplayId(
    String? value,
    List<Ministry> ministries,
    List<Church> churches,
  ) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final type = parts[0] == 'church' ? EntityType.church : EntityType.ministry;
    final id = parts[1];
    if (type == EntityType.ministry && ministries.any((m) => m.id == id)) {
      return PreferredEntity(id: id, type: type);
    }
    if (type == EntityType.church && churches.any((c) => c.id == id)) {
      return PreferredEntity(id: id, type: type);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);
    final churchState = ref.watch(churchControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final ministries = ministryState.ministries;
    final churches = churchState.churches;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final allEntities = <ReligiousEntity>[...ministries, ...churches];
    final preferredEntity = _getValidPreferredEntity(
      ministryState.preferredEntity,
      ministries,
      churches,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsPreferredEntitySection,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (allEntities.isEmpty)
          Text(
            l10n.settingsNoEntitiesAvailable,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: _getEntityDisplayId(preferredEntity),
            decoration: InputDecoration(
              labelText: l10n.settingsPreferredEntityLabel,
              hintText: l10n.settingsPreferredEntityHint,
            ),
            items: [
              // Ministries
              ...ministries.map((ministry) {
                return DropdownMenuItem<String>(
                  value: 'ministry:${ministry.id}',
                  child: Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(ministry.name),
                    ],
                  ),
                );
              }),
              // Churches
              ...churches.map((church) {
                return DropdownMenuItem<String>(
                  value: 'church:${church.id}',
                  child: Row(
                    children: [
                      Icon(
                        Icons.church,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(church.name),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {
              final entity = _parseEntityDisplayId(value, ministries, churches);
              if (entity != null) {
                ref
                    .read(ministryControllerProvider.notifier)
                    .setPreferredEntity(entity, user.uid);
              }
            },
          ),
      ],
    );
  }
}

/// Delete account section widget
class _DeleteAccountSection extends ConsumerWidget {
  const _DeleteAccountSection({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settingsState = ref.watch(settingsControllerProvider);
    final ministryState = ref.watch(ministryControllerProvider);

    // Check if user is administrator
    final isAdministrator = ministryState.ministries.any(
      (m) => m.administratorId == user.uid,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        if (isAdministrator)
          Tooltip(
            message: l10n.settingsDeleteAccountAdministratorRestriction,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              child: Text(l10n.settingsDeleteAccountButton),
            ),
          )
        else
          ElevatedButton(
            onPressed: settingsState.isDeleting
                ? null
                : () => _showDeleteConfirmation(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: settingsState.isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.settingsDeleteAccountButton),
          ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountTitle),
        content: Text(l10n.settingsDeleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.settingsDeleteAccountCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.settingsDeleteAccountConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(settingsControllerProvider.notifier)
          .deleteAccount(user.uid);

      if (!context.mounted) return;

      if (success) {
        // Clear preferences
        final preferencesService = ref.read(preferencesServiceProvider);
        await preferencesService.clearUserPreferences(user.uid);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.settingsAccountDeleted)));

          // Navigate to login
          context.goNamed('login');
        }
      } else {
        final error = ref.read(settingsControllerProvider).error;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? l10n.settingsAccountDeleteError),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
