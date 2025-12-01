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

    final church = await ref
        .read(churchControllerProvider.notifier)
        .createChurch(
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);
    final ministries = ministryState.ministries;

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
                          setState(() {
                            _selectedType = newSelection.first;
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
                        ),
                        textCapitalization: TextCapitalization.words,
                        enabled: !_isCreating,
                        autofocus: true,
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
                          items: ministries.map((ministry) {
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
                      onPressed: _isCreating ? null : _createEntity,
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
