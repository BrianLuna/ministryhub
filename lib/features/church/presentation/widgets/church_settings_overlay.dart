import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Church settings overlay shown as a bottom sheet
class ChurchSettingsOverlay extends ConsumerStatefulWidget {
  const ChurchSettingsOverlay({required this.church, super.key});

  final Church church;

  /// Show the overlay as a bottom sheet
  static Future<void> show(BuildContext context, Church church) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChurchSettingsOverlay(church: church),
    );
  }

  @override
  ConsumerState<ChurchSettingsOverlay> createState() =>
      _ChurchSettingsOverlayState();
}

class _ChurchSettingsOverlayState extends ConsumerState<ChurchSettingsOverlay> {
  final _nameController = TextEditingController();
  Location? _selectedLocation;
  Ministry? _selectedMinistry;
  bool _nameChanged = false;
  bool _locationChanged = false;
  bool _ministryChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.church.name;
    _selectedLocation = widget.church.location;
    _nameController.addListener(() {
      if (_nameController.text != widget.church.name) {
        setState(() {
          _nameChanged = true;
        });
      } else {
        setState(() {
          _nameChanged = false;
        });
      }
    });

    // Load current ministry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ministryState = ref.read(ministryControllerProvider);
      Ministry? ministry;
      try {
        ministry = ministryState.ministries.firstWhere(
          (m) => m.id == widget.church.ministryId,
        );
      } catch (e) {
        ministry = ministryState.ministries.isNotEmpty
            ? ministryState.ministries.first
            : null;
      }
      setState(() {
        _selectedMinistry = ministry;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final church = widget.church;
    bool hasChanges = false;

    // Update name if changed
    if (_nameChanged && _nameController.text.trim() != church.name) {
      final success = await ref
          .read(churchControllerProvider.notifier)
          .updateChurch(
            ministryId: church.ministryId,
            churchId: church.id,
            name: _nameController.text.trim(),
          );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.churchUpdateError),
            ),
          );
        }
        return;
      }
      hasChanges = true;
    }

    // Update location if changed
    if (_locationChanged && _selectedLocation != null) {
      final success = await ref
          .read(churchControllerProvider.notifier)
          .updateChurch(
            ministryId: church.ministryId,
            churchId: church.id,
            location: _selectedLocation,
          );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.churchUpdateError),
            ),
          );
        }
        return;
      }
      hasChanges = true;
    }

    // Update ministry if changed
    if (_ministryChanged &&
        _selectedMinistry != null &&
        _selectedMinistry!.id != church.ministryId) {
      final success = await ref
          .read(churchControllerProvider.notifier)
          .updateChurch(
            ministryId: church.ministryId,
            churchId: church.id,
            newMinistryId: _selectedMinistry!.id,
          );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.churchUpdateError),
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
          content: Text(AppLocalizations.of(context)!.churchUpdateSuccess),
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
    final churchState = ref.watch(churchControllerProvider);
    final ministryState = ref.watch(ministryControllerProvider);
    final church = widget.church;
    final ministries = ministryState.ministries;

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
                    l10n.churchSettingsTitle,
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
                  // Name Section
                  _NameSection(
                    nameController: _nameController,
                    nameChanged: _nameChanged,
                  ),
                  const SizedBox(height: 24),
                  // Location Section
                  _LocationSection(
                    initialLocation: _selectedLocation,
                    onLocationChanged: (location) {
                      setState(() {
                        _selectedLocation = location;
                        _locationChanged = true;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Ministry Section
                  _MinistrySection(
                    selectedMinistry: _selectedMinistry,
                    ministries: ministries,
                    onMinistryChanged: (ministry) {
                      setState(() {
                        _selectedMinistry = ministry;
                        _ministryChanged = true;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Save button
                  ElevatedButton(
                    onPressed:
                        (churchState.isSaving ||
                            churchState.isDeleting ||
                            (!_nameChanged &&
                                !_locationChanged &&
                                !_ministryChanged))
                        ? null
                        : _saveChanges,
                    child: churchState.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.churchSave),
                  ),
                  const SizedBox(height: 24),
                  // Delete church button
                  _DeleteChurchSection(church: church),
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
        Text(l10n.churchNameLabel, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.churchNameLabel,
            hintText: l10n.churchNameHint,
          ),
          textCapitalization: TextCapitalization.words,
          enabled: !nameChanged || nameController.text.trim().isNotEmpty,
        ),
      ],
    );
  }
}

/// Location section widget
class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.initialLocation,
    required this.onLocationChanged,
  });

  final Location? initialLocation;
  final ValueChanged<Location> onLocationChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.churchLocationLabel, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        LocationPicker(
          initialLocation: initialLocation,
          onLocationSelected: onLocationChanged,
        ),
      ],
    );
  }
}

/// Ministry section widget
class _MinistrySection extends StatelessWidget {
  const _MinistrySection({
    required this.selectedMinistry,
    required this.ministries,
    required this.onMinistryChanged,
  });

  final Ministry? selectedMinistry;
  final List<Ministry> ministries;
  final ValueChanged<Ministry> onMinistryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.churchMinistryLabel, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        DropdownButtonFormField<Ministry>(
          initialValue: selectedMinistry,
          decoration: InputDecoration(
            labelText: l10n.churchMinistryLabel,
            hintText: l10n.churchMinistryHint,
          ),
          items: ministries.map((ministry) {
            return DropdownMenuItem<Ministry>(
              value: ministry,
              child: Text(ministry.name),
            );
          }).toList(),
          onChanged: (ministry) {
            if (ministry != null) {
              onMinistryChanged(ministry);
            }
          },
        ),
      ],
    );
  }
}

/// Delete church section widget
class _DeleteChurchSection extends ConsumerWidget {
  const _DeleteChurchSection({required this.church});

  final Church church;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final churchState = ref.watch(churchControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: churchState.isDeleting || churchState.isSaving
              ? null
              : () => _showDeleteConfirmation(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: churchState.isDeleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.churchDeleteButton),
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
        title: Text(l10n.churchDeleteTitle),
        content: Text(l10n.churchDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.churchDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.churchDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(churchControllerProvider.notifier)
          .deleteChurch(church.ministryId, church.id);

      if (!context.mounted) return;

      if (success) {
        Navigator.of(context).pop(); // Close settings overlay
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.churchDeleteSuccess)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.churchDeleteError)));
      }
    }
  }
}
