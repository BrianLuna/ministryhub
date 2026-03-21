import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Dialog for creating a new ministry
class CreateMinistryDialog extends ConsumerStatefulWidget {
  const CreateMinistryDialog({super.key});

  /// Show the create ministry dialog
  static Future<Ministry?> show(BuildContext context) async {
    return showDialog<Ministry?>(
      context: context,
      builder: (context) => const CreateMinistryDialog(),
    );
  }

  @override
  ConsumerState<CreateMinistryDialog> createState() =>
      _CreateMinistryDialogState();
}

enum _EntityType { ministry, church }

class _CreateMinistryDialogState extends ConsumerState<CreateMinistryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  _EntityType _selectedType = _EntityType.ministry;
  Ministry? _selectedMinistry;
  Location? _selectedLocation;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Determines if the create button should be enabled
  bool get _canCreate {
    if (_isCreating) return false;

    final name = _nameController.text.trim();
    if (name.isEmpty) return false;

    if (_selectedType == _EntityType.church) {
      // For church: name, ministry, and location are required
      if (_selectedMinistry == null) return false;
      if (_selectedLocation == null) return false;
    }

    return true;
  }

  Future<void> _createEntity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == _EntityType.church) {
      await _createChurch();
      return;
    }

    await _createMinistry();
  }

  Future<void> _createMinistry() async {
    setState(() {
      _isCreating = true;
    });

    final authState = ref.read(authControllerProvider);
    final user = authState.user;
    if (user == null) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final ministry = await ref
        .read(ministryControllerProvider.notifier)
        .createMinistry(
          name: _nameController.text.trim(),
          administratorId: user.uid,
        );

    if (mounted) {
      if (ministry != null) {
        // Capture ref before closing the dialog to avoid disposed widget issues
        final ministryController = ref.read(
          ministryControllerProvider.notifier,
        );

        // Close the create dialog first
        Navigator.of(context).pop(ministry);

        // Show paywall bottom sheet
        // Use the controller directly instead of ref to avoid disposed widget issues
        await PaywallBottomSheet.show(
          context,
          ministryId: ministry.id,
          onSubscriptionSelected: (subscriptionType) async {
            // Update ministry with selected subscription using the controller
            // This avoids using ref after widget disposal
            if (subscriptionType != SubscriptionType.free) {
              await ministryController.updateSubscription(
                ministryId: ministry.id,
                subscriptionType: subscriptionType,
                package: null, // No package in mock mode
              );
            }
          },
        );

        // If user selected free or cancelled, ministry already has free subscription
        // No need to do anything else
      } else {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _createChurch() async {
    if (_selectedMinistry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.churchMinistryRequired),
        ),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.churchLocationRequired),
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final churchController = ref.read(churchControllerProvider.notifier);
    final church = await churchController.createChurch(
      name: _nameController.text.trim(),
      location: _selectedLocation!,
      ministryId: _selectedMinistry!.id,
    );

    if (mounted) {
      if (church != null) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isCreating = false;
        });

        final churchState = ref.read(churchControllerProvider);
        final error = churchState.error;
        if (error != null && _selectedMinistry != null) {
          await _showSubscriptionUpgradeDialog(error, _selectedMinistry!);
        }
      }
    }
  }

  Future<void> _showSubscriptionUpgradeDialog(
    String errorMessage,
    Ministry ministry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ministryController = ref.read(ministryControllerProvider.notifier);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.churchUpdateError),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.settingsPreferredEntitySection,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.churchCancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await PaywallBottomSheet.show(
                  context,
                  ministryId: ministry.id,
                  onSubscriptionSelected: (subscriptionType) async {
                    if (subscriptionType != SubscriptionType.free) {
                      await ministryController.updateSubscription(
                        ministryId: ministry.id,
                        subscriptionType: subscriptionType,
                        package: null,
                      );
                    }
                  },
                );
              },
              child: Text(l10n.entitySettings),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);
    final ministries = ministryState.ministries;
    // Deduplicate ministries to avoid duplicate dropdown values
    final uniqueMinistries = ministries.toSet().toList();

    // Ensure selected ministry is part of the current list; otherwise reset
    if (_selectedMinistry != null &&
        !uniqueMinistries.contains(_selectedMinistry)) {
      _selectedMinistry = null;
    }

    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: mediaQuery.size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(l10n.entityCreateTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Segmented button for entity type
                      SegmentedButton<_EntityType>(
                        segments: [
                          ButtonSegment(
                            value: _EntityType.ministry,
                            label: Text(l10n.entityTypeMinistry),
                          ),
                          ButtonSegment(
                            value: _EntityType.church,
                            label: Text(l10n.entityTypeChurch),
                          ),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (Set<_EntityType> newSelection) {
                          final newType = newSelection.first;
                          setState(() {
                            _selectedType = newType;
                            if (newType == _EntityType.church) {
                              final ministryState =
                                  ref.read(ministryControllerProvider);
                              final current =
                                  ministryState.selectedMinistry;
                              if (current != null) {
                                Ministry? match;
                                for (final m in ministryState.ministries) {
                                  if (m.id == current.id) {
                                    match = m;
                                    break;
                                  }
                                }
                                _selectedMinistry = match;
                              }
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: _selectedType == _EntityType.ministry
                              ? l10n.ministryNameLabel
                              : l10n.churchNameLabel,
                          hintText: _selectedType == _EntityType.ministry
                              ? l10n.ministryNameHint
                              : l10n.churchNameHint,
                          suffixIcon: _nameController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _nameController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        enabled: !_isCreating,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final trimmedValue = value?.trim() ?? '';
                          if (trimmedValue.isEmpty) {
                            return _selectedType == _EntityType.ministry
                                ? l10n.ministryNameRequired
                                : l10n.churchNameRequired;
                          }
                          if (trimmedValue.length < 2) {
                            return _selectedType == _EntityType.ministry
                                ? l10n.ministryNameTooShort
                                : l10n.churchNameTooShort;
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _createEntity(),
                      ),
                      if (_selectedType == _EntityType.church) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Ministry>(
                          initialValue: _selectedMinistry,
                          decoration: InputDecoration(
                            labelText: l10n.churchMinistryLabel,
                            hintText: l10n.churchMinistryHint,
                          ),
                          items: uniqueMinistries.map((ministry) {
                            return DropdownMenuItem<Ministry>(
                              value: ministry,
                              child: Text(ministry.name),
                            );
                          }).toList(),
                          onChanged: _isCreating
                              ? null
                              : (ministry) {
                                  setState(() {
                                    _selectedMinistry = ministry;
                                  });
                                },
                          validator: (value) {
                            if (_selectedType != _EntityType.church) {
                              return null;
                            }
                            if (value == null) {
                              return l10n.churchMinistryRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.churchLocationLabel,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        // Location picker area (search + suggestions + map)
                        Expanded(
                          child: LocationPicker(
                            initialLocation: _selectedLocation,
                            onLocationSelected: (location) {
                              setState(() {
                                _selectedLocation = location;
                              });
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Actions
              Align(
                alignment: Alignment.centerRight,
                child: OverflowBar(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: _isCreating
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(l10n.ministryCancel),
                    ),
                    ElevatedButton(
                      onPressed: _canCreate ? _createEntity : null,
                      child: _isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _selectedType == _EntityType.ministry
                                  ? l10n.ministryCreate
                                  : l10n.churchCreate,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
