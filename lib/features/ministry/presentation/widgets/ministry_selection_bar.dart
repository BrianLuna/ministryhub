import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ministryhub/ministryhub.dart';

/// Modern entity selection bar displayed below the AppBar
/// Shows both ministries and churches in a unified dropdown
class MinistrySelectionBar extends ConsumerWidget {
  const MinistrySelectionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ministryState = ref.watch(ministryControllerProvider);
    final churchState = ref.watch(churchControllerProvider);

    final selectedMinistry = ministryState.selectedMinistry;
    final selectedChurch = churchState.selectedChurch;
    final ministries = ministryState.ministries;
    final churches = churchState.churches;
    final isLoading = ministryState.isLoading || churchState.isLoading;

    // Determine selected entity
    ReligiousEntity? selectedEntity;
    if (selectedChurch != null) {
      selectedEntity = selectedChurch;
    } else if (selectedMinistry != null) {
      selectedEntity = selectedMinistry;
    }

    // Combine entities for dropdown
    final allEntities = <ReligiousEntity>[...ministries, ...churches];

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
          // Entity selector
          Expanded(
            child: _EntityDropdown(
              entities: allEntities,
              selectedEntity: selectedEntity,
              isLoading: isLoading,
              onEntitySelected: (entity) {
                if (entity == null) {
                  ref
                      .read(ministryControllerProvider.notifier)
                      .selectMinistry(null);
                  ref
                      .read(churchControllerProvider.notifier)
                      .selectChurch(null);
                } else if (entity.entityType == EntityType.ministry) {
                  ref
                      .read(ministryControllerProvider.notifier)
                      .selectMinistry(entity as Ministry);
                  ref
                      .read(churchControllerProvider.notifier)
                      .selectChurch(null);
                } else {
                  ref
                      .read(churchControllerProvider.notifier)
                      .selectChurch(entity as Church);
                  ref
                      .read(ministryControllerProvider.notifier)
                      .selectMinistry(null);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // Settings button
          IconButton(
            onPressed: selectedEntity == null
                ? null
                : () {
                    final entity = selectedEntity;
                    if (entity != null) {
                      if (entity.entityType == EntityType.ministry) {
                        MinistrySettingsOverlay.show(
                          context,
                          entity as Ministry,
                        );
                      } else {
                        ChurchSettingsOverlay.show(context, entity as Church);
                      }
                    }
                  },
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.entitySettings,
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
          // Create entity button
          IconButton(
            onPressed: () async {
              final result = await CreateMinistryDialog.show(context);
              if (result != null && context.mounted) {
                // Result is always Ministry from CreateMinistryDialog
                ref
                    .read(ministryControllerProvider.notifier)
                    .selectMinistry(result);
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l10n.entityCreate,
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern dropdown for entity selection (ministries and churches)
class _EntityDropdown extends StatelessWidget {
  const _EntityDropdown({
    required this.entities,
    required this.selectedEntity,
    required this.isLoading,
    required this.onEntitySelected,
  });

  final List<ReligiousEntity> entities;
  final ReligiousEntity? selectedEntity;
  final bool isLoading;
  final ValueChanged<ReligiousEntity?> onEntitySelected;

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

    if (entities.isEmpty) {
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
            l10n.entityNoEntities,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return MenuAnchor(
      menuChildren: [
        // Ministries section
        if (entities.any((e) => e.entityType == EntityType.ministry)) ...[
          SubmenuButton(
            leadingIcon: const Icon(Icons.business),
            menuChildren: [
              for (final entity in entities.where(
                (e) => e.entityType == EntityType.ministry,
              ))
                MenuItemButton(
                  onPressed: () {
                    onEntitySelected(entity);
                  },
                  child: _EntityMenuItem(
                    entity: entity,
                    isSelected: selectedEntity?.id == entity.id,
                  ),
                ),
            ],
            child: Text(l10n.entityTypeMinistry),
          ),
        ],
        // Churches section
        if (entities.any((e) => e.entityType == EntityType.church)) ...[
          SubmenuButton(
            leadingIcon: const Icon(Icons.church),
            menuChildren: [
              for (final entity in entities.where(
                (e) => e.entityType == EntityType.church,
              ))
                MenuItemButton(
                  onPressed: () {
                    onEntitySelected(entity);
                  },
                  child: _EntityMenuItem(
                    entity: entity,
                    isSelected: selectedEntity?.id == entity.id,
                  ),
                ),
            ],
            child: Text(l10n.entityTypeChurch),
          ),
        ],
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
                // Icon based on entity type
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    (selectedEntity?.entityType ?? EntityType.ministry) ==
                            EntityType.church
                        ? Icons.church
                        : Icons.business,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedEntity?.name ?? l10n.entitySelectEntity,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: selectedEntity != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: selectedEntity != null
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

/// Menu item widget for entity
class _EntityMenuItem extends StatelessWidget {
  const _EntityMenuItem({required this.entity, required this.isSelected});

  final ReligiousEntity entity;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          entity.entityType == EntityType.church
              ? Icons.church
              : Icons.business,
          size: 18,
          color: entity.entityType == EntityType.church
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            entity.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: entity.entityType == EntityType.church
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (isSelected)
          Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
      ],
    );
  }
}
