import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/router/taxonomy_query_params.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_kind.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_node.dart';

/// Flat Taxonomy List View (SH-ADM-14).
/// Renders a flat, single-level list of category or region nodes,
/// dimmed inactive rows with explicit "Inactive" text badges (accessibility §40/§56),
/// show/hide inactive filtering, and URL query param synchronization.
class TaxonomyListView extends StatefulWidget {
  const TaxonomyListView({
    super.key,
    required this.nodes,
    required this.kind,
    this.selectedId,
    required this.showInactive,
    this.onNodeSelected,
    this.onToggleShowInactive,
  });

  final List<TaxonomyNode> nodes;
  final TaxonomyKind kind;
  final String? selectedId;
  final bool showInactive;
  final ValueChanged<TaxonomyNode>? onNodeSelected;
  final VoidCallback? onToggleShowInactive;

  @override
  State<TaxonomyListView> createState() => _TaxonomyListViewState();
}

class _TaxonomyListViewState extends State<TaxonomyListView> {
  String _searchFilter = '';

  List<TaxonomyNode> _filterNodes(List<TaxonomyNode> rawNodes) {
    final query = _searchFilter.trim().toLowerCase();

    return rawNodes.where((node) {
      if (!widget.showInactive && !node.isActive) {
        return false;
      }
      if (query.isEmpty) return true;
      return node.nameEn.toLowerCase().contains(query) ||
          node.nameAr.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    final displayNodes = _filterNodes(widget.nodes);

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        borderRadius: shapes.roundedMd,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: spacing.inputHeight - 4,
                    child: TextField(
                      key: const Key('taxonomy-search-field'),
                      style: typography.bodySmall.copyWith(color: colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Filter ${widget.kind.displayName.toLowerCase()}...',
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: colors.textMuted,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchFilter = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: spacing.sm),

                // Show/Hide Inactive Toggle
                Tooltip(
                  message: widget.showInactive
                      ? (l10n?.hideInactive ?? 'Hide Inactive')
                      : (l10n?.showInactive ?? 'Show Inactive'),
                  child: InkWell(
                    key: const Key('taxonomy-toggle-inactive-button'),
                    borderRadius: shapes.roundedSm,
                    onTap: () {
                      context.updateTaxonomyQuery(
                        showInactive: !widget.showInactive,
                      );
                      widget.onToggleShowInactive?.call();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: widget.showInactive
                            ? colors.gold400.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: shapes.roundedSm,
                        border: Border.all(
                          color: widget.showInactive
                              ? colors.gold400
                              : colors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.showInactive
                                ? Icons.visibility
                                : Icons.visibility_off_outlined,
                            size: 16,
                            color: widget.showInactive
                                ? colors.goldPrimary
                                : colors.textMuted,
                          ),
                          SizedBox(width: spacing.xxs),
                          Text(
                            widget.showInactive
                                ? (l10n?.hideInactive ?? 'Hide Inactive')
                                : (l10n?.showInactive ?? 'Show Inactive'),
                            style: typography.caption.copyWith(
                              color: widget.showInactive
                                  ? colors.goldPrimary
                                  : colors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colors.borderSubtle),

          // Flat List
          Expanded(
            child: displayNodes.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.lg),
                      child: Text(
                        _searchFilter.isNotEmpty
                            ? 'No matches found for "$_searchFilter"'
                            : 'No ${widget.kind.displayName.toLowerCase()} available.',
                        style: typography.bodySmall.copyWith(color: colors.textMuted),
                      ),
                    ),
                  )
                : ListView.builder(
                    key: const Key('taxonomy-tree-list'),
                    padding: EdgeInsets.symmetric(vertical: spacing.xs),
                    itemCount: displayNodes.length,
                    itemBuilder: (context, index) {
                      return _buildRow(node: displayNodes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({required TaxonomyNode node}) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    final isSelected = widget.selectedId == node.id;
    final isInactive = !node.isActive;

    Widget rowContent = Container(
      key: Key('taxonomy-node-${node.id}'),
      margin: EdgeInsets.symmetric(
        horizontal: spacing.xs,
        vertical: 1,
      ),
      padding: EdgeInsets.only(
        left: spacing.sm,
        right: spacing.md,
        top: spacing.xs,
        bottom: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? colors.gold400.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: shapes.roundedSm,
        border: Border.all(
          color: isSelected ? colors.gold400 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Category/Region Icon (if present)
          if (node.icon != null && node.icon!.isNotEmpty) ...[
            Icon(
              _resolveIconData(node.icon!),
              size: 16,
              color: isSelected ? colors.goldPrimary : colors.textSecondary,
            ),
            SizedBox(width: spacing.xs),
          ],

          // Name English & Arabic
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    node.nameEn,
                    overflow: TextOverflow.ellipsis,
                    style: typography.subtitle.copyWith(
                      color: isSelected ? colors.goldPrimary : colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: spacing.sm),
                Flexible(
                  child: Text(
                    node.nameAr,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: typography.caption.copyWith(
                      color: isSelected
                          ? colors.gold300
                          : colors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: spacing.sm),

          // Display order indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: colors.backgroundSurface,
              borderRadius: shapes.roundedXs,
            ),
            child: Text(
              '#${node.displayOrder}',
              style: typography.caption.copyWith(
                color: colors.textMuted,
                fontSize: 10,
              ),
            ),
          ),

          // Inactive text badge (per accessibility §40/§56, NEVER color-only)
          if (isInactive) ...[
            SizedBox(width: spacing.xs),
            KhStatusChip(
              key: Key('inactive-badge-${node.id}'),
              label: l10n?.statusInactive ?? 'Inactive',
              tone: KhStatusTone.error,
              icon: Icons.pause_circle_outline,
              dense: true,
            ),
          ],
        ],
      ),
    );

    // Dim inactive rows via Opacity
    if (isInactive) {
      rowContent = Opacity(
        opacity: 0.65,
        child: rowContent,
      );
    }

    return InkWell(
      onTap: () {
        context.updateTaxonomyQuery(selectedId: node.id);
        widget.onNodeSelected?.call(node);
      },
      child: rowContent,
    );
  }

  IconData _resolveIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'diamond':
        return Icons.diamond_outlined;
      case 'category':
        return Icons.category_outlined;
      case 'watch':
        return Icons.watch_outlined;
      case 'ring':
      case 'stars':
        return Icons.auto_awesome_outlined;
      case 'coin':
      case 'toll':
        return Icons.toll_outlined;
      case 'monetization_on':
        return Icons.monetization_on_outlined;
      case 'sell':
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'location_on':
      case 'public':
        return Icons.public_outlined;
      case 'apartment':
        return Icons.apartment_outlined;
      default:
        return Icons.label_outline;
    }
  }
}
