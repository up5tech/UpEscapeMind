import 'package:flutter/material.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../data/content/content_strings.dart';
import '../../domain/models/content/content_models.dart';

/// Bottom inventory bar shown inside the room screen. Lists collected
/// items; tapping an item opens its detail sheet (use / combine).
///
/// Transient selection state (item in hand, combine mode) is owned by the
/// parent — durable state lives in `GameProgress`.
class InventoryBar extends StatelessWidget {
  const InventoryBar({
    super.key,
    required this.items,
    required this.strings,
    required this.locale,
    required this.l10n,
    required this.selectedItemId,
    required this.combineMode,
    required this.combineSelection,
    required this.onItemTap,
    required this.onCombine,
    required this.onExitCombine,
    required this.onDeselect,
    required this.onOpenSheet,
  });

  /// Collected items in inventory order.
  final List<ItemDefinition> items;
  final ContentStrings strings;
  final String locale;
  final AppLocalizations l10n;

  final String? selectedItemId;
  final bool combineMode;
  final Set<String> combineSelection;

  /// Bar tap: toggles combine selection in combine mode, otherwise opens
  /// the detail sheet.
  final void Function(ItemDefinition item) onItemTap;
  final VoidCallback onCombine;
  final VoidCallback onExitCombine;
  final VoidCallback onDeselect;
  final void Function(ItemDefinition item) onOpenSheet;

  String _name(ItemDefinition item) => strings.forLocale(locale, item.nameKey);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(top: BorderSide(color: AppColors.brass, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (combineMode)
              _CombineBanner(
                l10n: l10n,
                selectedCount: combineSelection.length,
                canCombine: combineSelection.length >= 2,
                onCombine: onCombine,
                onExit: onExitCombine,
              )
            else if (selectedItemId != null)
              _SelectedBanner(
                l10n: l10n,
                itemName: _nameOf(selectedItemId!),
                onDeselect: onDeselect,
              ),
            SizedBox(
              height: 72,
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        l10n.inventoryEmpty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final isSelected = selectedItemId == item.id;
                        final inCombine = combineSelection.contains(item.id);
                        return _ItemChip(
                          item: item,
                          name: _name(item),
                          isSelected: isSelected,
                          inCombine: inCombine,
                          combineMode: combineMode,
                          onTap: () =>
                              combineMode ? onItemTap(item) : onOpenSheet(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _nameOf(String itemId) {
    for (final item in items) {
      if (item.id == itemId) return _name(item);
    }
    return itemId;
  }
}

class _CombineBanner extends StatelessWidget {
  const _CombineBanner({
    required this.l10n,
    required this.selectedCount,
    required this.canCombine,
    required this.onCombine,
    required this.onExit,
  });

  final AppLocalizations l10n;
  final int selectedCount;
  final bool canCombine;
  final VoidCallback onCombine;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${l10n.itemCombineAction} ($selectedCount)',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.amber),
            ),
          ),
          TextButton(
            onPressed: canCombine ? onCombine : null,
            child: Text(l10n.itemCombineAction),
          ),
          TextButton(onPressed: onExit, child: Text(l10n.combineExitAction)),
        ],
      ),
    );
  }
}

class _SelectedBanner extends StatelessWidget {
  const _SelectedBanner({
    required this.l10n,
    required this.itemName,
    required this.onDeselect,
  });

  final AppLocalizations l10n;
  final String itemName;
  final VoidCallback onDeselect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.itemUsingHint(itemName),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.amber),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: l10n.itemDeselectAction,
            onPressed: onDeselect,
          ),
        ],
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  const _ItemChip({
    required this.item,
    required this.name,
    required this.isSelected,
    required this.inCombine,
    required this.combineMode,
    required this.onTap,
  });

  final ItemDefinition item;
  final String name;
  final bool isSelected;
  final bool inCombine;
  final bool combineMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = inCombine || isSelected
        ? AppColors.amber
        : AppColors.secondaryText;
    return Semantics(
      button: true,
      label: name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    item.iconAsset,
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    semanticLabel: name,
                  ),
                  if (inCombine)
                    const Positioned(
                      right: -4,
                      top: -4,
                      child: Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.amber,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: AppColors.primaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item detail sheet: inspection info plus Use / Combine actions.
/// Returns nothing; actions are delegated to [onUse], [onCombineStart].
Future<void> showItemDetailSheet({
  required BuildContext context,
  required ItemDefinition item,
  required ContentStrings strings,
  required String locale,
  required AppLocalizations l10n,
  required bool isSelected,
  required VoidCallback onUse,
  required VoidCallback onCombineStart,
}) {
  final name = strings.forLocale(locale, item.nameKey);
  final description = strings.forLocale(locale, item.descriptionKey);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryText,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Image.asset(
                    item.inspectionAsset ?? item.iconAsset,
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                    semanticLabel: name,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(sheetContext).textTheme.bodyMedium
                    ?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        onUse();
                      },
                      child: Text(
                        isSelected
                            ? l10n.itemDeselectAction
                            : l10n.itemUseAction,
                      ),
                    ),
                  ),
                  if (item.canBeCombined) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          onCombineStart();
                        },
                        child: Text(l10n.itemCombineAction),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
