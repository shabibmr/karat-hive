import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/design/theme/kh_theme.dart';
import '../../../core/router/taxonomy_query_params.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/taxonomy_controller.dart';
import '../model/taxonomy_dto.dart';
import '../model/taxonomy_kind.dart';
import '../model/taxonomy_node.dart';
import 'node_editor_panel.dart';
import 'taxonomy_tree.dart';

/// Taxonomy Management Screen unifying ADM-S14 (Categories) and ADM-S15 (Regions).
/// Integrates 2-level expandable tree, responsive node editor panel,
/// empty states (SH-FND-12), validation/error banners (SH-FND-13),
/// and toast notifications (SH-FND-17).
class TaxonomyScreen extends ConsumerStatefulWidget {
  const TaxonomyScreen({
    super.key,
    required this.kind,
    this.initialSelectedId,
    this.initialShowInactive = false,
  });

  final TaxonomyKind kind;
  final String? initialSelectedId;
  final bool initialShowInactive;

  @override
  ConsumerState<TaxonomyScreen> createState() => _TaxonomyScreenState();
}

class _TaxonomyScreenState extends ConsumerState<TaxonomyScreen> {
  EditorMode _editorMode = EditorMode.edit;
  bool _isSubmitting = false;
  String? _panelErrorMessage;
  String? _localSelectedId;
  late bool _localShowInactive;

  @override
  void initState() {
    super.initState();
    _localSelectedId = widget.initialSelectedId;
    _localShowInactive = widget.initialShowInactive;
  }

  TaxonomyNode? _findNodeById(List<TaxonomyNode> nodes, String? id) {
    if (id == null || id.isEmpty) return null;
    for (final node in nodes) {
      if (node.id == id) return node;
      for (final child in node.children) {
        if (child.id == id) return child;
      }
    }
    return null;
  }

  TaxonomyNode? _findParentOf(List<TaxonomyNode> nodes, String? childId) {
    if (childId == null || childId.isEmpty) return null;
    for (final parent in nodes) {
      for (final child in parent.children) {
        if (child.id == childId) return parent;
      }
    }
    return null;
  }

  void _showSuccessToast(String message) {
    final colors = context.kh.colors;
    final shapes = context.kh.shapes;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('taxonomy-success-toast'),
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: colors.sapphire900, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.sapphire900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.gold400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: shapes.roundedSm),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    return str;
  }

  Future<void> _handleSave(String id, UpdateTaxonomyDto dto) async {
    setState(() {
      _isSubmitting = true;
      _panelErrorMessage = null;
    });

    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(taxonomyControllerProvider(widget.kind).notifier)
          .updateNode(id, dto);

      if (mounted) {
        final msg = widget.kind == TaxonomyKind.category
            ? (l10n?.toastCategoryUpdated ?? 'Category updated successfully.')
            : (l10n?.toastRegionUpdated ?? 'Region updated successfully.');
        _showSuccessToast(msg);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _panelErrorMessage = _formatErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleCreate(CreateTaxonomyDto dto) async {
    setState(() {
      _isSubmitting = true;
      _panelErrorMessage = null;
    });

    final l10n = AppLocalizations.of(context);
    try {
      final created = await ref
          .read(taxonomyControllerProvider(widget.kind).notifier)
          .createNode(dto);

      if (mounted) {
        setState(() {
          _editorMode = EditorMode.edit;
        });
        context.updateTaxonomyQuery(selectedId: created.id);

        final msg = widget.kind == TaxonomyKind.category
            ? (l10n?.toastCategoryCreated ?? 'Category created successfully.')
            : (l10n?.toastRegionCreated ?? 'Region created successfully.');
        _showSuccessToast(msg);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _panelErrorMessage = _formatErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleDeactivate(String id) async {
    setState(() {
      _isSubmitting = true;
      _panelErrorMessage = null;
    });

    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(taxonomyControllerProvider(widget.kind).notifier)
          .deactivateNode(id);

      if (mounted) {
        final msg = widget.kind == TaxonomyKind.category
            ? (l10n?.toastCategoryDeactivated ??
                'Category deactivated successfully.')
            : (l10n?.toastRegionDeactivated ??
                'Region deactivated successfully.');
        _showSuccessToast(msg);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _panelErrorMessage = _formatErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  TaxonomyQueryParams _getQueryParams(BuildContext context) {
    try {
      final query = TaxonomyQueryParams.fromState(GoRouterState.of(context));
      return query.selectedId != null
          ? query
          : query.copyWith(selectedId: _localSelectedId);
    } catch (_) {
      return TaxonomyQueryParams(
        selectedId: _localSelectedId,
        showInactive: _localShowInactive,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    final query = _getQueryParams(context);
    final asyncNodes = ref.watch(taxonomyControllerProvider(widget.kind));

    final isCategory = widget.kind == TaxonomyKind.category;
    final title = isCategory
        ? (l10n?.categoriesTitle ?? 'Category Management')
        : (l10n?.regionsTitle ?? 'Region Management');
    final subtitle = isCategory
        ? (l10n?.categoriesSubtitle ??
            'Manage two-level product category taxonomy for requests and vendor specialisations.')
        : (l10n?.regionsSubtitle ??
            'Manage geographic matching taxonomy (emirates and areas) for marketplace routing.');

    return Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Title & Subtitle Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typography.displayL),
                    SizedBox(height: spacing.xxs),
                    Text(
                      subtitle,
                      style: typography.bodySmall.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.md),
              // Refresh button
              IconButton(
                key: const Key('taxonomy-refresh-button'),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                color: colors.textSecondary,
                onPressed: () {
                  ref.read(taxonomyControllerProvider(widget.kind).notifier).reload();
                },
              ),
            ],
          ),

          SizedBox(height: spacing.lg),

          // Main Screen Body
          Expanded(
            child: asyncNodes.when(
              loading: () => const Center(
                key: Key('loading-view'),
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                key: const Key('error-view'),
                child: Container(
                  padding: EdgeInsets.all(spacing.xl),
                  constraints: const BoxConstraints(maxWidth: 480),
                  decoration: BoxDecoration(
                    color: colors.backgroundElevated,
                    borderRadius: shapes.roundedMd,
                    border: Border.all(color: colors.error.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colors.error),
                      SizedBox(height: spacing.md),
                      Text(
                        'Failed to load ${widget.kind.displayName.toLowerCase()}',
                        style: typography.title.copyWith(color: colors.cream100),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        _formatErrorMessage(error),
                        textAlign: TextAlign.center,
                        style: typography.bodySmall.copyWith(color: colors.textMuted),
                      ),
                      SizedBox(height: spacing.lg),
                      OutlinedButton(
                        onPressed: () {
                          ref
                              .read(taxonomyControllerProvider(widget.kind).notifier)
                              .reload();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (nodes) {
                // Empty state (SH-FND-12)
                if (nodes.isEmpty) {
                  return Center(
                    key: const Key('empty-view'),
                    child: Container(
                      padding: EdgeInsets.all(spacing.xxl),
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: colors.backgroundElevated,
                        borderRadius: shapes.roundedMd,
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCategory
                                ? Icons.category_outlined
                                : Icons.public_outlined,
                            size: 56,
                            color: colors.goldPrimary,
                          ),
                          SizedBox(height: spacing.md),
                          Text(
                            isCategory
                                ? (l10n?.emptyCategoriesTitle ??
                                    'No Categories Found')
                                : (l10n?.emptyRegionsTitle ??
                                    'No Regions Found'),
                            style: typography.title,
                          ),
                          SizedBox(height: spacing.sm),
                          Text(
                            isCategory
                                ? (l10n?.emptyCategoriesBody ??
                                    'No product categories have been configured yet. Create a root category to start building the taxonomy.')
                                : (l10n?.emptyRegionsBody ??
                                    'No regions have been configured yet. Create a root emirate or region to begin.'),
                            textAlign: TextAlign.center,
                            style: typography.bodySmall
                                .copyWith(color: colors.textSecondary),
                          ),
                          SizedBox(height: spacing.xl),
                          ElevatedButton.icon(
                            key: const Key('empty-state-cta-button'),
                            onPressed: () {
                              setState(() {
                                _editorMode = EditorMode.createRoot;
                              });
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              isCategory
                                  ? (l10n?.addRootCategory ?? '+ Add Category')
                                  : (l10n?.addRootRegion ?? '+ Add Region'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final selectedNode = _findNodeById(nodes, query.selectedId);
                final parentNode = _findParentOf(nodes, query.selectedId);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;

                    final treeWidget = TaxonomyTree(
                      nodes: nodes,
                      kind: widget.kind,
                      selectedId: query.selectedId,
                      showInactive: query.showInactive,
                      onNodeSelected: (node) {
                        setState(() {
                          _localSelectedId = node.id;
                          _editorMode = EditorMode.edit;
                          _panelErrorMessage = null;
                        });
                      },
                      onCreateRoot: () {
                        setState(() {
                          _localSelectedId = null;
                          _editorMode = EditorMode.createRoot;
                          _panelErrorMessage = null;
                        });
                      },
                      onToggleShowInactive: () {
                        setState(() {
                          _localShowInactive = !_localShowInactive;
                        });
                      },
                    );

                    final editorWidget = NodeEditorPanel(
                      kind: widget.kind,
                      selectedNode: selectedNode,
                      parentNode: parentNode,
                      mode: _editorMode,
                      isSubmitting: _isSubmitting,
                      errorMessage: _panelErrorMessage,
                      onSave: _handleSave,
                      onCreate: _handleCreate,
                      onDeactivate: _handleDeactivate,
                      onCancelCreate: () {
                        setState(() {
                          _editorMode = EditorMode.edit;
                          _panelErrorMessage = null;
                        });
                      },
                      onRequestCreateChild: () {
                        setState(() {
                          _editorMode = EditorMode.createChild;
                          _panelErrorMessage = null;
                        });
                      },
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: treeWidget,
                          ),
                          SizedBox(width: spacing.md),
                          SizedBox(
                            width: 420,
                            child: editorWidget,
                          ),
                        ],
                      );
                    } else {
                      // Stacked view for compact viewports
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 380,
                              child: treeWidget,
                            ),
                            SizedBox(height: spacing.md),
                            editorWidget,
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
