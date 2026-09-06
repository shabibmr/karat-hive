import 'package:flutter/material.dart';

import '../../../core/design/theme/kh_theme.dart';
import '../../../core/router/taxonomy_query_params.dart';
import '../../../l10n/app_localizations.dart';
import '../model/taxonomy_kind.dart';
import '../model/taxonomy_node.dart';

/// 2-Level Expandable Taxonomy Tree View (SH-ADM-14).
/// Renders hierarchical category and region trees with expand/collapse,
/// dimmed inactive rows with explicit "Inactive" text badges (accessibility §40/§56),
/// show/hide inactive filtering, and URL query param synchronization.
class TaxonomyTree extends StatefulWidget {
  const TaxonomyTree({
    super.key,
    required this.nodes,
    required this.kind,
    this.selectedId,
    required this.showInactive,
    this.onNodeSelected,
    this.onCreateRoot,
    this.onToggleShowInactive,
  });

  final List<TaxonomyNode> nodes;
  final TaxonomyKind kind;
  final String? selectedId;
  final bool showInactive;
  final ValueChanged<TaxonomyNode>? onNodeSelected;
  final VoidCallback? onCreateRoot;
  final VoidCallback? onToggleShowInactive;

  @override
  State<TaxonomyTree> createState() => _TaxonomyTreeState();
}

class _TaxonomyTreeState extends State<TaxonomyTree> {
  final Set<String> _expandedNodeIds = {};
  String _searchFilter = '';

  @override
  void initState() {
    super.initState();
    _expandAllRoots();
  }

  @override
  void didUpdateWidget(covariant TaxonomyTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodes != widget.nodes) {
      _expandAllRoots();
    }
  }

  void _expandAllRoots() {
    for (final node in widget.nodes) {
      _expandedNodeIds.add(node.id);
    }
  }

  void _toggleExpanded(String nodeId) {
    setState(() {
      if (_expandedNodeIds.contains(nodeId)) {
        _expandedNodeIds.remove(nodeId);
      } else {
        _expandedNodeIds.add(nodeId);
      }
    });
  }

  List<TaxonomyNode> _filterNodes(List<TaxonomyNode> rawNodes) {
    final query = _searchFilter.trim().toLowerCase();

    return rawNodes.where((parent) {
      if (!widget.showInactive && !parent.isActive) {
        return false;
      }

      final parentMatches = query.isEmpty ||
          parent.nameEn.toLowerCase().contains(query) ||
          parent.nameAr.toLowerCase().contains(query);

      final matchingChildren = parent.children.where((child) {
        if (!widget.showInactive && !child.isActive) {
          return false;
        }
        if (query.isEmpty) return true;
        return child.nameEn.toLowerCase().contains(query) ||
            child.nameAr.toLowerCase().contains(query);
      }).toList();

      return parentMatches || matchingChildren.isNotEmpty;
    }).map((parent) {
      final filteredChildren = parent.children.where((child) {
        if (!widget.showInactive && !child.isActive) {
          return false;
        }
        if (query.isEmpty) return true;
        final parentMatches = parent.nameEn.toLowerCase().contains(query) ||
            parent.nameAr.toLowerCase().contains(query);
        return parentMatches ||
            child.nameEn.toLowerCase().contains(query) ||
            child.nameAr.toLowerCase().contains(query);
      }).toList();

      return parent.copyWith(children: filteredChildren);
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

                SizedBox(width: spacing.sm),

                // Add Root Node CTA
                OutlinedButton.icon(
                  key: const Key('taxonomy-add-root-button'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    minimumSize: Size(32, spacing.inputHeight - 4),
                  ),
                  onPressed: () {
                    context.updateTaxonomyQuery(clearSelected: true);
                    widget.onCreateRoot?.call();
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    widget.kind == TaxonomyKind.category
                        ? (l10n?.addRootCategory ?? '+ Add Category')
                        : (l10n?.addRootRegion ?? '+ Add Region'),
                    style: typography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colors.borderSubtle),

          // Tree List
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
                      final rootNode = displayNodes[index];
                      final isExpanded = _expandedNodeIds.contains(rootNode.id);
                      final hasChildren = rootNode.children.isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildRow(
                            node: rootNode,
                            level: 0,
                            hasChildren: hasChildren,
                            isExpanded: isExpanded,
                          ),
                          if (isExpanded && hasChildren)
                            ...rootNode.children.map(
                              (child) => _buildRow(
                                node: child,
                                level: 1,
                                hasChildren: false,
                                isExpanded: false,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required TaxonomyNode node,
    required int level,
    required bool hasChildren,
    required bool isExpanded,
  }) {
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
        left: level == 0 ? spacing.sm : spacing.treeIndent + spacing.sm,
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
          // Expand/collapse chevron or level bullet
          if (level == 0)
            InkWell(
              borderRadius: shapes.roundedXs,
              onTap: hasChildren ? () => _toggleExpanded(node.id) : null,
              child: Padding(
                padding: EdgeInsets.all(spacing.xxs),
                child: Icon(
                  hasChildren
                      ? (isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right)
                      : Icons.fiber_manual_record,
                  size: hasChildren ? 18 : 8,
                  color: hasChildren
                      ? (isSelected ? colors.goldPrimary : colors.textSecondary)
                      : colors.textMuted.withValues(alpha: 0.4),
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.xs),
              child: Icon(
                Icons.subdirectory_arrow_right,
                size: 14,
                color: colors.textMuted,
              ),
            ),

          SizedBox(width: spacing.xs),

          // Category/Region Icon (if present)
          if (node.icon != null && node.icon!.isNotEmpty) ...[
            Icon(
              _resolveIconData(node.icon!),
              size: 16,
              color: isSelected ? colors.goldPrimary : colors.cream200,
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
                    style: (level == 0
                            ? typography.subtitle
                            : typography.bodySmall)
                        .copyWith(
                      color: isSelected ? colors.goldPrimary : colors.textPrimary,
                      fontWeight: level == 0 ? FontWeight.w600 : FontWeight.w400,
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
              color: colors.sapphire700,
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
            Container(
              key: Key('inactive-badge-${node.id}'),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.15),
                borderRadius: shapes.pill,
                border: Border.all(
                  color: colors.error.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pause_circle_outline, size: 10, color: colors.error),
                  const SizedBox(width: 3),
                  Text(
                    l10n?.statusInactive ?? 'Inactive',
                    style: typography.caption.copyWith(
                      color: colors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
