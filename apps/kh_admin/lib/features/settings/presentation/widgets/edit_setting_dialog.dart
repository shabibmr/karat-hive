import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/settings/controller/platform_settings_controller.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';

/// Typed setting editing dialog with validation against allowedRange and
/// Super-Admin confirmation. Was `_EditSettingDialog` in
/// `platform_settings_screen.dart` (TR-S2-11).
class EditSettingDialog extends ConsumerStatefulWidget {
  const EditSettingDialog({super.key, required this.item});

  final PlatformSettingItem item;

  @override
  ConsumerState<EditSettingDialog> createState() => _EditSettingDialogState();
}

class _EditSettingDialogState extends ConsumerState<EditSettingDialog> {
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
