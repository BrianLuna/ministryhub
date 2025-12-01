import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Dialog for deleting a ministry with options to handle associated churches
class DeleteMinistryDialog extends ConsumerStatefulWidget {
  const DeleteMinistryDialog({
    required this.ministry,
    required this.churchCount,
    super.key,
  });

  final Ministry ministry;
  final int churchCount;

  /// Show the delete ministry dialog
  static Future<bool> show(
    BuildContext context,
    Ministry ministry,
    int churchCount,
  ) async {
    if (churchCount == 0) {
      // No churches, show simple confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.ministryDeleteTitle),
          content: Text(AppLocalizations.of(context)!.ministryDeleteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.ministryDeleteCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppLocalizations.of(context)!.ministryDeleteConfirm),
            ),
          ],
        ),
      );
      return confirmed ?? false;
    }

    // Has churches, show dialog with options
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          DeleteMinistryDialog(ministry: ministry, churchCount: churchCount),
    );
    return result ?? false;
  }

  @override
  ConsumerState<DeleteMinistryDialog> createState() =>
      _DeleteMinistryDialogState();
}

class _DeleteMinistryDialogState extends ConsumerState<DeleteMinistryDialog> {
  MinistryDeletionStrategy _strategy = MinistryDeletionStrategy.deleteChurches;
  Ministry? _targetMinistry;
  bool _isDeleting = false;

  Future<void> _confirmDelete() async {
    if (_strategy == MinistryDeletionStrategy.reassignChurches &&
        _targetMinistry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.ministryReassignTargetRequired,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    final success = await ref
        .read(ministryControllerProvider.notifier)
        .deleteMinistry(
          ministryId: widget.ministry.id,
          strategy: _strategy,
          targetMinistryId: _targetMinistry?.id,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ministryDeleteError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);
    final availableMinistries = ministryState.ministries
        .where((m) => m.id != widget.ministry.id)
        .toList();

    return AlertDialog(
      title: Text(l10n.ministryDeleteWithChurchesTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.ministryDeleteWithChurchesMessage(widget.churchCount)),
            const SizedBox(height: 24),
            // Strategy selection
            IgnorePointer(
              ignoring: _isDeleting,
              child: RadioGroup<MinistryDeletionStrategy>(
                groupValue: _strategy,
                onChanged: (value) {
                  setState(() {
                    _strategy = value!;
                    if (value == MinistryDeletionStrategy.deleteChurches) {
                      _targetMinistry = null;
                    }
                  });
                },
                child: Column(
                  children: [
                    RadioListTile<MinistryDeletionStrategy>(
                      title: Text(l10n.ministryDeleteChurchesOption),
                      subtitle: Text(
                        l10n.ministryDeleteChurchesOptionDescription,
                      ),
                      value: MinistryDeletionStrategy.deleteChurches,
                    ),
                    RadioListTile<MinistryDeletionStrategy>(
                      title: Text(l10n.ministryReassignChurchesOption),
                      subtitle: Text(
                        l10n.ministryReassignChurchesOptionDescription,
                      ),
                      value: MinistryDeletionStrategy.reassignChurches,
                    ),
                  ],
                ),
              ),
            ),
            // Target ministry selector (only show if reassign is selected)
            if (_strategy == MinistryDeletionStrategy.reassignChurches) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<Ministry>(
                initialValue: _targetMinistry,
                decoration: InputDecoration(
                  labelText: l10n.ministryReassignTargetLabel,
                  hintText: l10n.ministryReassignTargetHint,
                ),
                items: availableMinistries.map((ministry) {
                  return DropdownMenuItem<Ministry>(
                    value: ministry,
                    child: Text(ministry.name),
                  );
                }).toList(),
                onChanged: _isDeleting
                    ? null
                    : (ministry) {
                        setState(() {
                          _targetMinistry = ministry;
                        });
                      },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(l10n.ministryDeleteCancel),
        ),
        TextButton(
          onPressed: _isDeleting ? null : _confirmDelete,
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          child: _isDeleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.ministryDeleteConfirm),
        ),
      ],
    );
  }
}
