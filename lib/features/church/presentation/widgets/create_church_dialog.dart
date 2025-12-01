import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Dialog for creating a new church
class CreateChurchDialog extends ConsumerStatefulWidget {
  const CreateChurchDialog({super.key});

  /// Show the create church dialog
  static Future<Church?> show(BuildContext context) async {
    return showDialog<Church?>(
      context: context,
      builder: (context) => const CreateChurchDialog(),
    );
  }

  @override
  ConsumerState<CreateChurchDialog> createState() => _CreateChurchDialogState();
}

class _CreateChurchDialogState extends ConsumerState<CreateChurchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Location? _selectedLocation;
  Ministry? _selectedMinistry;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createChurch() async {
    if (!_formKey.currentState!.validate()) {
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

    if (_selectedMinistry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.churchMinistryRequired),
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
        Navigator.of(context).pop(church);
      } else {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);
    final ministries = ministryState.ministries;

    return AlertDialog(
      title: Text(l10n.churchCreateTitle),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.churchNameLabel,
                    hintText: l10n.churchNameHint,
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isCreating,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.churchNameRequired;
                    }
                    if (value.trim().length < 2) {
                      return l10n.churchNameTooShort;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _createChurch(),
                ),
                const SizedBox(height: 16),
                // Ministry selector
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
                    if (value == null) {
                      return l10n.churchMinistryRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Location picker
                Text(
                  l10n.churchLocationLabel,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                LocationPicker(
                  initialLocation: _selectedLocation,
                  onLocationSelected: (location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.churchCancel),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createChurch,
          child: _isCreating
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.churchCreate),
        ),
      ],
    );
  }
}
