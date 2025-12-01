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
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createEntity() async {
    if (_selectedType == _EntityType.church) {
      // For church, close this dialog and open create church dialog
      if (mounted) {
        Navigator.of(context).pop();
        await CreateChurchDialog.show(context);
      }
      return;
    }

    // For ministry, validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Create ministry
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.entityCreateTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            // Show name field only for ministry
            if (_selectedType == _EntityType.ministry)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.ministryNameLabel,
                  hintText: l10n.ministryNameHint,
                ),
                textCapitalization: TextCapitalization.words,
                enabled: !_isCreating,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.ministryNameRequired;
                  }
                  if (value.trim().length < 2) {
                    return l10n.ministryNameTooShort;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _createEntity(),
              )
            else
              // For church, show message to continue
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  l10n.churchCreateDialogMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
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
    );
  }
}
