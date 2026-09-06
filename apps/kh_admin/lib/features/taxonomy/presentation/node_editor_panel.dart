import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/theme/kh_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../model/taxonomy_dto.dart';
import '../model/taxonomy_kind.dart';
import '../model/taxonomy_node.dart';

/// Available icon keys for Category nodes.
const List<String> kTaxonomyIcons = [
  'diamond',
  'watch',
  'ring',
  'coin',
  'sell',
  'category',
  'stars',
  'shopping_bag',
  'location_on',
  'apartment',
];

/// Editor panel modes.
enum EditorMode {
  edit,
  createRoot,
  createChild,
}

/// Node Editor Panel Widget (SH-ADM-08).
/// Provides side-panel editing for Category and Region taxonomy nodes.
/// Supports English & RTL Arabic names, category icon selection, displayOrder,
/// active toggle, child creation, and safe deactivation with SH-FND-15 confirm dialog.
///
/// STRICT SPEC RULE (SAM-GAP-9): The word "Delete" must NEVER be shown.
/// Only "Deactivate" is used.
class NodeEditorPanel extends StatefulWidget {
  const NodeEditorPanel({
    super.key,
    required this.kind,
    this.selectedNode,
    this.parentNode,
    this.mode = EditorMode.edit,
    required this.onSave,
    required this.onCreate,
    required this.onDeactivate,
    this.onCancelCreate,
    this.onRequestCreateChild,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final TaxonomyKind kind;
  final TaxonomyNode? selectedNode;
  final TaxonomyNode? parentNode;
  final EditorMode mode;
  final Future<void> Function(String id, UpdateTaxonomyDto dto) onSave;
  final Future<void> Function(CreateTaxonomyDto dto) onCreate;
  final Future<void> Function(String id) onDeactivate;
  final VoidCallback? onCancelCreate;
  final VoidCallback? onRequestCreateChild;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  State<NodeEditorPanel> createState() => _NodeEditorPanelState();
}

class _NodeEditorPanelState extends State<NodeEditorPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameEnController;
  late TextEditingController _nameArController;
  late TextEditingController _displayOrderController;
  String? _selectedIcon;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController();
    _nameArController = TextEditingController();
    _displayOrderController = TextEditingController();
    _initFromNode();
  }

  @override
  void didUpdateWidget(covariant NodeEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedNode != widget.selectedNode ||
        oldWidget.mode != widget.mode ||
        oldWidget.parentNode != widget.parentNode) {
      _initFromNode();
    }
  }

  void _initFromNode() {
    if (widget.mode == EditorMode.edit && widget.selectedNode != null) {
      final node = widget.selectedNode!;
      _nameEnController.text = node.nameEn;
      _nameArController.text = node.nameAr;
      _displayOrderController.text = node.displayOrder.toString();
      _selectedIcon = node.icon;
      _isActive = node.isActive;
    } else {
      _nameEnController.clear();
      _nameArController.clear();
      _displayOrderController.text = '0';
      _selectedIcon = widget.kind == TaxonomyKind.category ? 'diamond' : null;
      _isActive = true;
    }
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nameEn = _nameEnController.text.trim();
    final nameAr = _nameArController.text.trim();
    final displayOrder = int.tryParse(_displayOrderController.text.trim()) ?? 0;

    if (widget.mode == EditorMode.edit && widget.selectedNode != null) {
      final dto = UpdateTaxonomyDto(
        nameEn: nameEn,
        nameAr: nameAr,
        icon: widget.kind == TaxonomyKind.category ? _selectedIcon : null,
        displayOrder: displayOrder,
        isActive: _isActive,
      );
      await widget.onSave(widget.selectedNode!.id, dto);
    } else {
      final parentId = widget.mode == EditorMode.createChild
          ? widget.parentNode?.id ?? widget.selectedNode?.id
          : null;

      final dto = CreateTaxonomyDto(
        parentId: parentId,
        nameEn: nameEn,
        nameAr: nameAr,
        icon: widget.kind == TaxonomyKind.category ? _selectedIcon : null,
        displayOrder: displayOrder,
        isActive: _isActive,
      );
      await widget.onCreate(dto);
    }
  }

  /// Prompts confirmation dialog for deactivation (SH-FND-15).
  /// Strictly avoids any "Delete" phrasing per SAM-GAP-9.
  Future<void> _showDeactivateConfirmation() async {
    if (widget.selectedNode == null) return;
    final node = widget.selectedNode!;
    final l10n = AppLocalizations.of(context);
    final colors = context.kh.colors;
    final typography = context.kh.typography;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.backgroundElevated,
          title: Text(
            l10n?.deactivateConfirmTitle(node.nameEn) ??
                'Deactivate "${node.nameEn}"?',
            style: typography.title.copyWith(color: colors.cream100),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              l10n?.deactivateConfirmBody(node.nameEn) ??
                  'Are you sure you want to deactivate "${node.nameEn}"? Inactive nodes cannot be selected for new requests, but existing associations are preserved. This action can be reversed later.',
              style: typography.bodySmall.copyWith(color: colors.cream200),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                l10n?.cancel ?? 'Cancel',
                style: typography.body.copyWith(color: colors.textMuted),
              ),
            ),
            ElevatedButton(
              key: const Key('confirm-deactivate-button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.cream100,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n?.confirmDeactivate ?? 'Deactivate',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await widget.onDeactivate(node.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    final isCategory = widget.kind == TaxonomyKind.category;
    final isEditing = widget.mode == EditorMode.edit && widget.selectedNode != null;
    final isCreatingChild = widget.mode == EditorMode.createChild;
    final isRootNode = widget.selectedNode?.parentId == null;
    final canCreateChild = isEditing && isRootNode;

    String panelTitle;
    if (widget.mode == EditorMode.createRoot) {
      panelTitle = isCategory
          ? (l10n?.createRootCategory ?? 'New Root Category')
          : (l10n?.createRootRegion ?? 'New Root Region');
    } else if (isCreatingChild) {
      final parentName = widget.parentNode?.nameEn ?? widget.selectedNode?.nameEn ?? '';
      panelTitle = isCategory
          ? '${l10n?.newChildCategory ?? "New Subcategory"} ($parentName)'
          : '${l10n?.newChildRegion ?? "New Area"} ($parentName)';
    } else if (isEditing) {
      panelTitle = isCategory
          ? (l10n?.editCategory ?? 'Edit Category')
          : (l10n?.editRegion ?? 'Edit Region');
    } else {
      panelTitle = l10n?.selectNodeToEdit ?? 'Select a node to view or edit';
    }

    if (!isEditing && widget.mode == EditorMode.edit) {
      return Container(
        decoration: BoxDecoration(
          color: colors.backgroundElevated,
          borderRadius: shapes.roundedMd,
          border: Border.all(color: colors.borderSubtle),
        ),
        padding: EdgeInsets.all(spacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCategory ? Icons.category_outlined : Icons.public_outlined,
                size: 48,
                color: colors.textMuted.withValues(alpha: 0.5),
              ),
              SizedBox(height: spacing.md),
              Text(
                panelTitle,
                textAlign: TextAlign.center,
                style: typography.body.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.lg),
              ElevatedButton.icon(
                onPressed: widget.onCancelCreate,
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

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        borderRadius: shapes.roundedMd,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Panel Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      panelTitle,
                      style: typography.title.copyWith(color: colors.goldPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.mode != EditorMode.edit)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: l10n?.cancel ?? 'Cancel',
                      onPressed: widget.onCancelCreate,
                    ),
                ],
              ),

              if (isEditing && !isRootNode) ...[
                SizedBox(height: spacing.xxs),
                Text(
                  'Child of: ${widget.parentNode?.nameEn ?? "Parent Node"}',
                  style: typography.caption.copyWith(color: colors.textMuted),
                ),
              ],

              SizedBox(height: spacing.md),
              Divider(height: 1, color: colors.borderSubtle),
              SizedBox(height: spacing.lg),

              // Inline Error Banner (SH-FND-13)
              if (widget.errorMessage != null) ...[
                Container(
                  key: const Key('node-editor-error-banner'),
                  padding: EdgeInsets.all(spacing.sm),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.12),
                    borderRadius: shapes.roundedSm,
                    border: Border.all(color: colors.error.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, size: 18, color: colors.error),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Text(
                          widget.errorMessage!,
                          style: typography.caption.copyWith(
                            color: colors.cream100,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.md),
              ],

              // English Name Input
              Text(
                l10n?.nameEnLabel ?? 'Name (English)',
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.xs),
              TextFormField(
                key: const Key('node-name-en-field'),
                controller: _nameEnController,
                textDirection: TextDirection.ltr,
                enabled: !widget.isSubmitting,
                style: typography.body.copyWith(color: colors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. Fine Jewellery / Dubai',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return l10n?.nameEnRequired ??
                        'English name is required and cannot be blank';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),

              // Arabic Name Input (RTL-aware)
              Text(
                l10n?.nameArLabel ?? 'Name (Arabic)',
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.xs),
              TextFormField(
                key: const Key('node-name-ar-field'),
                controller: _nameArController,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                enabled: !widget.isSubmitting,
                style: typography.body.copyWith(color: colors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'مثال: مجوهرات فاخرة / دبي',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return l10n?.nameArRequired ??
                        'Arabic name is required and cannot be blank';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),

              // Category Icon Selector (Categories only)
              if (isCategory) ...[
                Text(
                  l10n?.iconLabel ?? 'Icon',
                  style: typography.label.copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: spacing.xs),
                DropdownButtonFormField<String>(
                  key: const Key('node-icon-selector'),
                  initialValue: _selectedIcon ?? 'diamond',
                  decoration: const InputDecoration(
                    isDense: true,
                  ),
                  dropdownColor: colors.sapphire800,
                  items: kTaxonomyIcons.map((iconName) {
                    return DropdownMenuItem<String>(
                      value: iconName,
                      child: Row(
                        children: [
                          Icon(
                            _resolveIconData(iconName),
                            size: 18,
                            color: colors.goldPrimary,
                          ),
                          SizedBox(width: spacing.sm),
                          Text(
                            iconName,
                            style: typography.bodySmall.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: widget.isSubmitting
                      ? null
                      : (val) {
                          setState(() {
                            _selectedIcon = val;
                          });
                        },
                ),
                SizedBox(height: spacing.md),
              ],

              // Display Order Input
              Text(
                l10n?.displayOrderLabel ?? 'Display Order',
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.xs),
              TextFormField(
                key: const Key('node-display-order-field'),
                controller: _displayOrderController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !widget.isSubmitting,
                style: typography.body.copyWith(color: colors.textPrimary),
                decoration: const InputDecoration(
                  hintText: '0',
                ),
              ),
              SizedBox(height: spacing.md),

              // Active Status Toggle
              Container(
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: colors.sapphire700.withValues(alpha: 0.5),
                  borderRadius: shapes.roundedSm,
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.activeStatusLabel ?? 'Active Status',
                            style: typography.label.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: spacing.xxs),
                          Text(
                            l10n?.activeStatusDescription ??
                                'Inactive nodes are hidden from customer/vendor selection but preserve associations.',
                            style: typography.caption.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      key: const Key('node-active-switch'),
                      value: _isActive,
                      activeTrackColor: colors.goldPrimary,
                      onChanged: widget.isSubmitting
                          ? null
                          : (val) {
                              setState(() {
                                _isActive = val;
                              });
                            },
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing.xl),

              // Primary Action (Save Changes or Create)
              ElevatedButton(
                key: const Key('node-save-button'),
                onPressed: widget.isSubmitting ? null : _handlePrimaryAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, spacing.buttonHeight + 4),
                ),
                child: widget.isSubmitting
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.sapphire900,
                          ),
                        ),
                      )
                    : Text(
                        widget.mode == EditorMode.edit
                            ? (l10n?.saveButton ?? 'Save Changes')
                            : (l10n?.createButton ?? 'Create'),
                      ),
              ),

              // Secondary Actions (Create Child & Deactivate)
              if (isEditing) ...[
                SizedBox(height: spacing.md),

                // Add Child Button (only if top-level node)
                if (canCreateChild)
                  OutlinedButton.icon(
                    key: const Key('node-create-child-button'),
                    onPressed: widget.isSubmitting
                        ? null
                        : widget.onRequestCreateChild,
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: Text(
                      isCategory
                          ? (l10n?.addChildCategory ?? 'Add Subcategory')
                          : (l10n?.addChildRegion ?? 'Add Area'),
                    ),
                  )
                else if (!isRootNode)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: spacing.xs),
                      child: Text(
                        l10n?.levelLimitReached ??
                            'Maximum hierarchy depth reached (2 levels).',
                        style: typography.caption.copyWith(
                          color: colors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: spacing.md),
                Divider(height: 1, color: colors.borderSubtle),
                SizedBox(height: spacing.md),

                if (widget.selectedNode?.isActive == true)
                  OutlinedButton.icon(
                    key: const Key('node-deactivate-button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(color: colors.error.withValues(alpha: 0.6)),
                    ),
                    onPressed: widget.isSubmitting
                        ? null
                        : _showDeactivateConfirmation,
                    icon: const Icon(Icons.pause_circle_outline, size: 16),
                    label: Text(
                      l10n?.deactivateButton ?? 'Deactivate',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
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
        return Icons.toll_outlined;
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
