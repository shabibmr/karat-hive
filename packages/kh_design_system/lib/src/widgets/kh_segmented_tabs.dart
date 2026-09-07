import 'package:flutter/material.dart';

import '../tokens.dart';
import 'kh_badge.dart';

class KhSegmentedTab {
  const KhSegmentedTab({
    required this.id,
    required this.label,
    this.count,
  });

  final String id;
  final String label;
  final int? count;
}

/// SH-FND-26 — segmented tab strip for list surfaces (e.g. My Offers).
class KhSegmentedTabs extends StatelessWidget {
  const KhSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
  });

  final List<KhSegmentedTab> tabs;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.space.sm),
        child: Row(
          children: [
            for (final tab in tabs) ...[
              _TabChip(
                tab: tab,
                selected: tab.id == selectedId,
                onTap: () => onSelected(tab.id),
              ),
              SizedBox(width: tokens.space.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final KhSegmentedTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = Text(
      tab.label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? tokens.ink : tokens.ink.withValues(alpha: 0.7),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
    );

    return Material(
      color: selected
          ? tokens.gold.withValues(alpha: 0.28)
          : tokens.ink.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(tokens.radius.lg),
      child: InkWell(
        key: Key('kh-segmented-tab-${tab.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.sm,
          ),
          child: tab.count == null
              ? label
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    label,
                    SizedBox(width: tokens.space.xs),
                    KhBadge(count: tab.count!),
                  ],
                ),
        ),
      ),
    );
  }
}
