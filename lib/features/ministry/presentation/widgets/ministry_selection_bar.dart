import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Modern ministry selection bar displayed below the AppBar
class MinistrySelectionBar extends ConsumerWidget {
  const MinistrySelectionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);
    final selectedMinistry = ministryState.selectedMinistry;
    final ministries = ministryState.ministries;
    final isLoading = ministryState.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Ministry selector
          Expanded(
            child: _MinistryDropdown(
              ministries: ministries,
              selectedMinistry: selectedMinistry,
              isLoading: isLoading,
              onMinistrySelected: (ministry) {
                ref
                    .read(ministryControllerProvider.notifier)
                    .selectMinistry(ministry);
              },
            ),
          ),
          const SizedBox(width: 12),
          // Create ministry button
          IconButton(
            onPressed: () async {
              final ministry = await CreateMinistryDialog.show(context);
              if (ministry != null && context.mounted) {
                ref
                    .read(ministryControllerProvider.notifier)
                    .selectMinistry(ministry);
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l10n.ministryCreate,
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
          // Settings button (only enabled when ministry is selected and exists in list)
          IconButton(
            onPressed:
                selectedMinistry == null ||
                    !ministries.any((m) => m.id == selectedMinistry.id)
                ? null
                : () {
                    MinistrySettingsOverlay.show(context, selectedMinistry);
                  },
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.ministrySettings,
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern dropdown for ministry selection
class _MinistryDropdown extends StatelessWidget {
  const _MinistryDropdown({
    required this.ministries,
    required this.selectedMinistry,
    required this.isLoading,
    required this.onMinistrySelected,
  });

  final List<Ministry> ministries;
  final Ministry? selectedMinistry;
  final bool isLoading;
  final ValueChanged<Ministry?> onMinistrySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (ministries.isEmpty) {
      return Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline.withAlpha(77)),
        ),
        child: Center(
          child: Text(
            l10n.ministryNoMinistries,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return MenuAnchor(
      menuChildren: [
        for (final ministry in ministries)
          MenuItemButton(
            onPressed: () {
              onMinistrySelected(ministry);
            },
            child: Row(
              children: [
                if (ministry.logoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      ministry.logoUrl!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.church,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.church,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(ministry.name, style: theme.textTheme.bodyMedium),
                ),
                if (selectedMinistry?.id == ministry.id)
                  Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
              ],
            ),
          ),
      ],
      builder: (context, controller, child) {
        return InkWell(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                if (selectedMinistry?.logoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      selectedMinistry!.logoUrl!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.church,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.church,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    selectedMinistry?.name ?? l10n.ministrySelectMinistry,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: selectedMinistry != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: selectedMinistry != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  controller.isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
