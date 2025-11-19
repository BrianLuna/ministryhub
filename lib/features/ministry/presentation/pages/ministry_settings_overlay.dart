import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Ministry settings overlay shown as a bottom sheet
class MinistrySettingsOverlay extends ConsumerStatefulWidget {
  const MinistrySettingsOverlay({required this.ministry, super.key});

  final Ministry ministry;

  /// Show the overlay as a bottom sheet
  static Future<void> show(BuildContext context, Ministry ministry) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MinistrySettingsOverlay(ministry: ministry),
    );
  }

  @override
  ConsumerState<MinistrySettingsOverlay> createState() =>
      _MinistrySettingsOverlayState();
}

class _MinistrySettingsOverlayState
    extends ConsumerState<MinistrySettingsOverlay> {
  final _nameController = TextEditingController();
  bool _nameChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.ministry.name;
    _nameController.addListener(() {
      if (_nameController.text != widget.ministry.name) {
        setState(() {
          _nameChanged = true;
        });
      } else {
        setState(() {
          _nameChanged = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final ministryState = ref.read(ministryControllerProvider);
    final ministry = widget.ministry;

    bool hasChanges = false;

    // Update name if changed
    if (_nameChanged && _nameController.text.trim() != ministry.name) {
      final success = await ref
          .read(ministryControllerProvider.notifier)
          .updateMinistry(
            ministryId: ministry.id,
            name: _nameController.text.trim(),
          );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.ministryUpdateError),
            ),
          );
        }
        return;
      }
      hasChanges = true;
    }

    // Upload logo if selected
    if (ministryState.selectedImage != null) {
      final success = await ref
          .read(ministryControllerProvider.notifier)
          .uploadLogo(ministry.id);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.ministryLogoUploadError,
              ),
            ),
          );
        }
        return;
      }
      hasChanges = true;
    }

    if (hasChanges && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ministryUpdateSuccess),
        ),
      );
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);
    final ministry = widget.ministry;

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
                Expanded(
                  child: Text(
                    l10n.ministrySettingsTitle,
                    style: theme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                  // Logo Section
                  _LogoSection(ministry: ministry),
                  const SizedBox(height: 24),
                  // Name Section
                  _NameSection(
                    nameController: _nameController,
                    nameChanged: _nameChanged,
                  ),
                  const SizedBox(height: 24),
                  // Save button
                  ElevatedButton(
                    onPressed:
                        (ministryState.isSaving ||
                            ministryState.isDeleting ||
                            (!_nameChanged &&
                                ministryState.selectedImage == null))
                        ? null
                        : _saveChanges,
                    child: ministryState.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.ministrySave),
                  ),
                  const SizedBox(height: 24),
                  // Delete ministry button
                  _DeleteMinistrySection(ministry: ministry),
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

/// Logo section widget
class _LogoSection extends ConsumerWidget {
  const _LogoSection({required this.ministry});

  final Ministry ministry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);

    ImageProvider? getLogoImage() {
      if (ministryState.selectedImagePath != null) {
        return FileImage(File(ministryState.selectedImagePath!));
      }
      if (ministry.logoUrl != null && ministry.logoUrl!.isNotEmpty) {
        return NetworkImage(ministry.logoUrl!);
      }
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ministryLogoLabel, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        // Logo
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  image: getLogoImage() != null
                      ? DecorationImage(
                          image: getLogoImage()!,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: getLogoImage() == null
                    ? Icon(
                        Icons.church,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: _buildCameraButton(context, ref, theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.camera_alt, size: 20),
        color: theme.colorScheme.onPrimary,
        onPressed: () => _showImageSourceDialog(context, ref),
      ),
    );
  }

  Future<void> _showImageSourceDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ministryLogoSourceTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.ministryLogoSourceGallery),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(ministryControllerProvider.notifier)
                    .pickImage(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.ministryLogoSourceCamera),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(ministryControllerProvider.notifier)
                    .pickImage(fromCamera: true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Name section widget
class _NameSection extends StatelessWidget {
  const _NameSection({required this.nameController, required this.nameChanged});

  final TextEditingController nameController;
  final bool nameChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ministryNameLabel, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.ministryNameLabel,
            hintText: l10n.ministryNameHint,
          ),
          textCapitalization: TextCapitalization.words,
          enabled: !nameChanged || nameController.text.trim().isNotEmpty,
        ),
      ],
    );
  }
}

/// Delete ministry section widget
class _DeleteMinistrySection extends ConsumerWidget {
  const _DeleteMinistrySection({required this.ministry});

  final Ministry ministry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: ministryState.isDeleting || ministryState.isSaving
              ? null
              : () => _showDeleteConfirmation(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: ministryState.isDeleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.ministryDeleteButton),
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
        title: Text(l10n.ministryDeleteTitle),
        content: Text(l10n.ministryDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.ministryDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.ministryDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(ministryControllerProvider.notifier)
          .deleteMinistry(ministry.id);

      if (!context.mounted) return;

      if (success) {
        Navigator.of(context).pop(); // Close settings overlay
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ministryDeleteSuccess)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ministryDeleteError)));
      }
    }
  }
}
