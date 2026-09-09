import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/settings/controller/platform_settings_controller.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';
import 'package:kh_admin/features/settings/model/platform_settings_state.dart';

/// ADM-S19 Platform Settings screen.
/// Surfaces global operational parameters, timeouts, trading constraints, and media limits.
class PlatformSettingsScreen extends ConsumerStatefulWidget {
  const PlatformSettingsScreen({super.key});

  @override
  ConsumerState<PlatformSettingsScreen> createState() =>
      _PlatformSettingsScreenState();
}

class _PlatformSettingsScreenState
    extends ConsumerState<PlatformSettingsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditSettingDialog(BuildContext context, PlatformSettingItem item) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _EditSettingDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final state = ref.watch(platformSettingsControllerProvider);
    final controller = ref.read(platformSettingsControllerProvider.notifier);

    // Show error snackbar if error occurs
    ref.listen<PlatformSettingsState>(platformSettingsControllerProvider,
        (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: kh.colors.error,
          ),
        );
      } else if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: kh.colors.success,
          ),
        );
      }
    });

    final filteredItems = state.filteredSettings;

    return SingleChildScrollView(
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Screen Header
          KhScreenHeader(
            eyebrow: 'PLATFORM GOVERNANCE',
            heading: 'Platform Settings',
            supportingText:
                'Global operational parameters, lifecycle timeouts, trading constraints, and media limits.',
            trailing: OutlinedButton.icon(
              key: const Key('refresh-settings-button'),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              onPressed: state.isLoading ? null : () => controller.refresh(),
            ),
          ),
          SizedBox(height: kh.spacing.lg),

          // 2. Metrics Overview Row
          _buildMetricsOverview(context, state),
          SizedBox(height: kh.spacing.lg),

          // 3. Pending Offer-Validity Architecture Decision Banner
          _buildOfferValidityNoticeBanner(context),
          SizedBox(height: kh.spacing.lg),

          // 4. Category Tabs & Search Bar
          _buildFilterBar(context, state, controller),
          SizedBox(height: kh.spacing.md),

          // 5. Settings Data Table
          if (state.isLoading && state.settings.isEmpty)
            Center(
              key: const Key('settings-list-loading'),
              child: Padding(
                padding: EdgeInsets.all(kh.spacing.xl),
                child: const CircularProgressIndicator(),
              ),
            )
          else if (state.errorMessage != null && state.settings.isEmpty)
            _buildErrorState(context, state.errorMessage!)
          else if (filteredItems.isEmpty)
            _buildEmptyState(context)
          else
            _buildSettingsTable(context, filteredItems),
        ],
      ),
    );
  }

  Widget _buildMetricsOverview(
      BuildContext context, PlatformSettingsState state) {
    final controller = ref.read(platformSettingsControllerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 36) / 4;
        final minWidth = cardWidth > 220 ? cardWidth : 220.0;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${state.settings.length}',
                label: 'TOTAL SETTINGS',
                linkText: 'All parameters',
                onTap: () => controller.selectCategory(null),
              ),
            ),
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${state.countByCategory(SettingCategory.lifecycle)}',
                label: 'LIFECYCLE RULES',
                linkText: 'View lifecycle',
                emphasized: state.selectedCategory == SettingCategory.lifecycle,
                onTap: () =>
                    controller.selectCategory(SettingCategory.lifecycle),
              ),
            ),
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${state.countByCategory(SettingCategory.limits)}',
                label: 'TRADING LIMITS',
                linkText: 'View limits',
                emphasized: state.selectedCategory == SettingCategory.limits,
                onTap: () => controller.selectCategory(SettingCategory.limits),
              ),
            ),
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${state.countByCategory(SettingCategory.media)}',
                label: 'MEDIA & STORAGE',
                linkText: 'View media',
                emphasized: state.selectedCategory == SettingCategory.media,
                onTap: () => controller.selectCategory(SettingCategory.media),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOfferValidityNoticeBanner(BuildContext context) {
    final kh = context.kh;

    return Container(
      key: const Key('offer-validity-decision-banner'),
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.warning.withValues(alpha: 0.12),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(
          color: kh.colors.warning.withValues(alpha: 0.6),
          width: kh.shapes.cardBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: kh.colors.warning, size: 24),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ARCHITECTURE DECISION PENDING: OFFER VALIDITY MODEL',
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.warning,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: kh.spacing.xs),
                    const KhStatusChip(
                      label: 'PENDING DECISION',
                      tone: KhStatusTone.pending,
                      dense: true,
                    ),
                  ],
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
                  'Offer validity option-set is flagged pending the live product decision. '
                  'This portal follows FR-VEN-013 / AD-API-07 (12 / 24 / 48 hours) and will not invent 72h or 168h options from the stale entity dictionary. '
                  'Per BR-020, configuration modifications apply only to entities created after the change and do not retroactively rewrite live Requests or Offers.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    PlatformSettingsState state,
    PlatformSettingsController controller,
  ) {
    final kh = context.kh;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip(
                context,
                label: 'All Settings (${state.settings.length})',
                isSelected: state.selectedCategory == null,
                onTap: () => controller.selectCategory(null),
              ),
              SizedBox(width: kh.spacing.xs),
              _buildCategoryChip(
                context,
                label:
                    'Lifecycle (${state.countByCategory(SettingCategory.lifecycle)})',
                isSelected:
                    state.selectedCategory == SettingCategory.lifecycle,
                onTap: () =>
                    controller.selectCategory(SettingCategory.lifecycle),
              ),
              SizedBox(width: kh.spacing.xs),
              _buildCategoryChip(
                context,
                label:
                    'Trading Limits (${state.countByCategory(SettingCategory.limits)})',
                isSelected: state.selectedCategory == SettingCategory.limits,
                onTap: () =>
                    controller.selectCategory(SettingCategory.limits),
              ),
              SizedBox(width: kh.spacing.xs),
              _buildCategoryChip(
                context,
                label:
                    'Media & Storage (${state.countByCategory(SettingCategory.media)})',
                isSelected: state.selectedCategory == SettingCategory.media,
                onTap: () => controller.selectCategory(SettingCategory.media),
              ),
              SizedBox(width: kh.spacing.xs),
              _buildCategoryChip(
                context,
                label:
                    'System & Security (${state.countByCategory(SettingCategory.security)})',
                isSelected:
                    state.selectedCategory == SettingCategory.security,
                onTap: () =>
                    controller.selectCategory(SettingCategory.security),
              ),
            ],
          ),
        ),
        SizedBox(height: kh.spacing.sm),

        // Search Field
        TextField(
          key: const Key('settings-search-field'),
          controller: _searchController,
          style: kh.typography.body.copyWith(color: kh.colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search settings by key, description, or value...',
            prefixIcon:
                Icon(Icons.search, size: 18, color: kh.colors.goldPrimary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      controller.setSearchQuery('');
                    },
                  )
                : null,
          ),
          onChanged: (val) => controller.setSearchQuery(val),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final kh = context.kh;

    return InkWell(
      onTap: onTap,
      borderRadius: kh.shapes.pill,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: kh.spacing.md,
          vertical: kh.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? kh.colors.goldPrimary.withValues(alpha: 0.18)
              : kh.colors.backgroundElevated,
          borderRadius: kh.shapes.pill,
          border: Border.all(
            color: isSelected
                ? kh.colors.goldPrimary
                : kh.colors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: kh.typography.bodySmall.copyWith(
            color: isSelected
                ? kh.colors.goldPrimary
                : kh.colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final kh = context.kh;
    return Container(
      key: const Key('settings-list-error'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.error.withValues(alpha: 0.1),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: kh.colors.error),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Text(
              message,
              style: kh.typography.body.copyWith(color: kh.colors.error),
            ),
          ),
          FilledButton(
            onPressed: () =>
                ref.read(platformSettingsControllerProvider.notifier).refresh(),
            style: FilledButton.styleFrom(
              backgroundColor: kh.colors.error,
              foregroundColor: kh.colors.cream100,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final kh = context.kh;

    return Container(
      key: const Key('settings-list-empty'),
      padding: EdgeInsets.all(kh.spacing.xl),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(Icons.tune_outlined, size: 40, color: kh.colors.mutedGold),
          SizedBox(height: kh.spacing.sm),
          Text(
            'No matching platform settings found',
            style: kh.typography.headline.copyWith(color: kh.colors.cream100),
          ),
          SizedBox(height: kh.spacing.xxs),
          Text(
            'Try adjusting your filter category or search keywords.',
            style:
                kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTable(
    BuildContext context,
    List<PlatformSettingItem> items,
  ) {
    final kh = context.kh;

    final columns = const [
      KhTableColumn('Setting Key & Description', flex: 4),
      KhTableColumn('Current Value', flex: 3),
      KhTableColumn('Type & Allowed Range', flex: 3),
      KhTableColumn('Security & Governance', flex: 2),
      KhTableColumn('Action', flex: 1),
    ];

    final rows = items.map((item) {
      return KhTableRow(
        key: Key('setting-row-${item.key}'),
        onTap: () => _showEditSettingDialog(context, item),
        cells: [
          // Cell 1: Key & Description & Badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.key,
                      style: kh.typography.body.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: kh.colors.goldPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.isOfferValidityPendingDecision) ...[
                    SizedBox(width: kh.spacing.xs),
                    const KhStatusChip(
                      label: 'Decision Pending',
                      tone: KhStatusTone.pending,
                      dense: true,
                    ),
                  ],
                ],
              ),
              if (item.description != null) ...[
                SizedBox(height: kh.spacing.xxs),
                Text(
                  item.description!,
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),

          // Cell 2: Current Value
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: kh.spacing.sm,
              vertical: kh.spacing.xs,
            ),
            decoration: BoxDecoration(
              color: kh.colors.backgroundSurface,
              borderRadius: kh.shapes.roundedSm,
              border: Border.all(color: kh.colors.borderSubtle),
            ),
            child: Text(
              item.formattedValue,
              style: kh.typography.bodySmall.copyWith(
                fontFamily: item.dataType == 'json' ||
                        item.dataType == 'number[]' ||
                        item.dataType == 'string[]'
                    ? 'monospace'
                    : null,
                color: kh.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Cell 3: Type & Allowed Range
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KhStatusChip(
                label: item.dataType.toUpperCase(),
                tone: KhStatusTone.neutral,
                dense: true,
              ),
              SizedBox(height: kh.spacing.xxs),
              Text(
                item.allowedRange?.summary ?? 'No range restrictions',
                style: kh.typography.caption.copyWith(
                  color: kh.colors.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Cell 4: Security & Governance
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KhStatusChip(
                label: item.requiresSuperAdmin
                    ? 'Super-Admin Confirm'
                    : 'Standard Admin',
                tone: item.requiresSuperAdmin
                    ? KhStatusTone.error
                    : KhStatusTone.success,
                dense: true,
              ),
              if (item.updatedAt != null) ...[
                SizedBox(height: kh.spacing.xxs),
                Text(
                  'Updated ${_formatDate(item.updatedAt!)}',
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),

          // Cell 5: Action
          OutlinedButton(
            key: Key('edit-setting-${item.key}'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: kh.spacing.sm,
                vertical: kh.spacing.xs,
              ),
              minimumSize: const Size(60, 32),
            ),
            onPressed: () => _showEditSettingDialog(context, item),
            child: const Text('Edit'),
          ),
        ],
      );
    }).toList(growable: false);

    return KhDataTable(
      columns: columns,
      rows: rows,
      minWidth: 900,
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}

/// Typed setting editing dialog with validation against allowedRange and Super-Admin confirmation.
class _EditSettingDialog extends ConsumerStatefulWidget {
  const _EditSettingDialog({required this.item});

  final PlatformSettingItem item;

  @override
  ConsumerState<_EditSettingDialog> createState() => _EditSettingDialogState();
}

class _EditSettingDialogState extends ConsumerState<_EditSettingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  late bool _booleanValue;
  String? _selectedEnumValue;
  bool _superAdminConfirmed = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    if (item.dataType == 'boolean') {
      _booleanValue = item.value == true;
      _valueController = TextEditingController();
    } else if (item.dataType == 'json' ||
        item.dataType == 'number[]' ||
        item.dataType == 'string[]') {
      if (item.value is Map || item.value is List) {
        _valueController = TextEditingController(
          text: const JsonEncoder.withIndent('  ').convert(item.value),
        );
      } else {
        _valueController =
            TextEditingController(text: item.value?.toString() ?? '');
      }
      _booleanValue = false;
    } else {
      _valueController =
          TextEditingController(text: item.value?.toString() ?? '');
      _booleanValue = false;
      if (item.allowedRange?.enumValues != null &&
          item.allowedRange!.enumValues!.contains(item.value?.toString())) {
        _selectedEnumValue = item.value?.toString();
      }
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  dynamic _parseValue() {
    final item = widget.item;
    if (item.dataType == 'boolean') {
      return _booleanValue;
    }

    if (item.allowedRange?.enumValues != null &&
        item.allowedRange!.enumValues!.isNotEmpty &&
        _selectedEnumValue != null) {
      return _selectedEnumValue;
    }

    final rawText = _valueController.text.trim();

    if (item.dataType == 'number' || item.dataType == 'money') {
      return num.tryParse(rawText) ?? rawText;
    }

    if (item.dataType == 'json' ||
        item.dataType == 'number[]' ||
        item.dataType == 'string[]') {
      try {
        return jsonDecode(rawText);
      } on Object catch (_) {
        return rawText;
      }
    }

    return rawText;
  }

  String? _validateInput(String? val) {
    final item = widget.item;
    if (val == null || val.trim().isEmpty) {
      return 'Setting value is required.';
    }

    if (item.dataType == 'number' || item.dataType == 'money') {
      final parsed = num.tryParse(val.trim());
      if (parsed == null) {
        return 'Please enter a valid number.';
      }
      final rangeError = item.allowedRange?.validate(parsed);
      if (rangeError != null) {
        return rangeError;
      }
    } else if (item.dataType == 'json' ||
        item.dataType == 'number[]' ||
        item.dataType == 'string[]') {
      try {
        jsonDecode(val.trim());
      } on Object catch (e) {
        return 'Invalid JSON format: ${e.toString()}';
      }
    } else {
      final rangeError = item.allowedRange?.validate(val.trim());
      if (rangeError != null) {
        return rangeError;
      }
    }

    return null;
  }

  Future<void> _handleSubmit() async {
    setState(() => _inlineError = null);

    if (widget.item.dataType != 'boolean') {
      if (widget.item.allowedRange?.enumValues != null &&
          widget.item.allowedRange!.enumValues!.isNotEmpty) {
        if (_selectedEnumValue == null) {
          setState(() => _inlineError = 'Please select a value from allowed list.');
          return;
        }
      } else if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    if (widget.item.requiresSuperAdmin && !_superAdminConfirmed) {
      setState(() =>
          _inlineError = 'Super-Admin confirmation is required for this parameter.');
      return;
    }

    final parsed = _parseValue();

    // Client-side range validation check
    final rangeError = widget.item.allowedRange?.validate(parsed);
    if (rangeError != null) {
      setState(() => _inlineError = rangeError);
      return;
    }

    final offerValidityError = widget.item.validateOfferValidity(parsed);
    if (offerValidityError != null) {
      setState(() => _inlineError = offerValidityError);
      return;
    }

    final controller =
        ref.read(platformSettingsControllerProvider.notifier);
    final success = await controller.updateSetting(
      widget.item.key,
      parsed,
      confirm: _superAdminConfirmed || widget.item.requiresSuperAdmin,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final err = ref.read(platformSettingsControllerProvider).errorMessage;
      setState(() => _inlineError = err ?? 'Failed to update setting.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final item = widget.item;
    final state = ref.watch(platformSettingsControllerProvider);

    return AlertDialog(
      backgroundColor: kh.colors.backgroundElevated,
      shape: RoundedRectangleBorder(
        borderRadius: kh.shapes.roundedLg,
        side: BorderSide(color: kh.colors.borderStandard),
      ),
      title: Row(
        children: [
          Icon(Icons.tune, color: kh.colors.goldPrimary, size: 20),
          SizedBox(width: kh.spacing.xs),
          Expanded(
            child: Text(
              'Edit Platform Setting',
              style: kh.typography.title.copyWith(color: kh.colors.cream100),
            ),
          ),
          KhStatusChip(
            label: item.dataType.toUpperCase(),
            tone: KhStatusTone.neutral,
            dense: true,
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Setting Key banner
                Container(
                  padding: EdgeInsets.all(kh.spacing.sm),
                  decoration: BoxDecoration(
                    color: kh.colors.backgroundSurface,
                    borderRadius: kh.shapes.roundedSm,
                    border: Border.all(color: kh.colors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.key,
                        style: kh.typography.body.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: kh.colors.goldPrimary,
                        ),
                      ),
                      if (item.description != null) ...[
                        SizedBox(height: kh.spacing.xxs),
                        Text(
                          item.description!,
                          style: kh.typography.bodySmall.copyWith(
                            color: kh.colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: kh.spacing.md),

                // Range specification hint
                if (item.allowedRange?.hasRestrictions == true) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: kh.spacing.sm,
                      vertical: kh.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: kh.colors.goldPrimary.withValues(alpha: 0.08),
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: kh.colors.goldPrimary),
                        SizedBox(width: kh.spacing.xs),
                        Expanded(
                          child: Text(
                            'Allowed Range: ${item.allowedRange!.summary}',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.goldPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: kh.spacing.md),
                ],

                // Typed Input Field
                _buildTypedEditor(context),
                SizedBox(height: kh.spacing.md),

                // Super-Admin Confirmation Box
                _buildConfirmationBox(context),

                // Inline Error display
                if (_inlineError != null) ...[
                  SizedBox(height: kh.spacing.sm),
                  Container(
                    padding: EdgeInsets.all(kh.spacing.sm),
                    decoration: BoxDecoration(
                      color: kh.colors.error.withValues(alpha: 0.15),
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            size: 16, color: kh.colors.error),
                        SizedBox(width: kh.spacing.xs),
                        Expanded(
                          child: Text(
                            _inlineError!,
                            key: const Key('edit-setting-inline-error'),
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: state.isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save-setting-button'),
          onPressed: state.isSaving ? null : _handleSubmit,
          child: state.isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildTypedEditor(BuildContext context) {
    final item = widget.item;

    if (item.dataType == 'boolean') {
      return SwitchListTile(
        key: const Key('setting-boolean-switch'),
        contentPadding: EdgeInsets.zero,
        title: Text(
          _booleanValue ? 'Enabled (true)' : 'Disabled (false)',
          style: context.kh.typography.body,
        ),
        subtitle: Text(
          'Toggle platform behavior for ${item.key}',
          style: context.kh.typography.caption,
        ),
        value: _booleanValue,
        activeThumbColor: context.kh.colors.goldPrimary,
        onChanged: (val) => setState(() => _booleanValue = val),
      );
    }

    if (item.allowedRange?.enumValues != null &&
        item.allowedRange!.enumValues!.isNotEmpty) {
      return DropdownButtonFormField<String>(
        key: const Key('setting-enum-dropdown'),
        initialValue: _selectedEnumValue,
        decoration: const InputDecoration(
          labelText: 'Selected Option *',
        ),
        items: item.allowedRange!.enumValues!
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => setState(() => _selectedEnumValue = val),
      );
    }

    final isMultiline = item.dataType == 'json' ||
        item.dataType == 'number[]' ||
        item.dataType == 'string[]';

    return TextFormField(
      key: const Key('setting-value-field'),
      controller: _valueController,
      maxLines: isMultiline ? 5 : 1,
      keyboardType: (item.dataType == 'number' || item.dataType == 'money')
          ? TextInputType.number
          : (isMultiline ? TextInputType.multiline : TextInputType.text),
      decoration: InputDecoration(
        labelText: 'Setting Value (${item.dataType}) *',
        hintText: isMultiline ? 'Enter valid JSON / Array...' : 'Enter new value...',
      ),
      validator: _validateInput,
    );
  }

  Widget _buildConfirmationBox(BuildContext context) {
    final kh = context.kh;
    final item = widget.item;

    final isSuperAdmin = item.requiresSuperAdmin;

    return Container(
      padding: EdgeInsets.all(kh.spacing.sm),
      decoration: BoxDecoration(
        color: isSuperAdmin
            ? kh.colors.error.withValues(alpha: 0.1)
            : kh.colors.backgroundSurface,
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(
          color: isSuperAdmin
              ? kh.colors.error.withValues(alpha: 0.6)
              : kh.colors.borderSubtle,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            key: const Key('super-admin-confirm-checkbox'),
            value: _superAdminConfirmed,
            activeColor:
                isSuperAdmin ? kh.colors.error : kh.colors.goldPrimary,
            onChanged: (val) =>
                setState(() => _superAdminConfirmed = val ?? false),
          ),
          SizedBox(width: kh.spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSuperAdmin
                      ? 'SUPER-ADMIN CONFIRMATION REQUIRED'
                      : 'Commercial Impact Confirmation (BR-020)',
                  style: kh.typography.caption.copyWith(
                    color: isSuperAdmin ? kh.colors.error : kh.colors.goldPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
                  'I confirm authorization to modify this operational parameter. Changes will take effect for future entities without modifying live records.',
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
