import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// SH-ID-05 — Review comment field (optional free text, max 1000 chars).
///
/// Domain specialization of [KhTextField] for leave-review flows
/// (`FR-CUS-029`, `FR-VEN-028`). Comment is optional; the 1000-char ceiling is
/// enforced here. Labels are passed in so callers own l10n.
class ReviewCommentField extends StatelessWidget {
  const ReviewCommentField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.helperText,
    this.minLines = 3,
    this.maxLines = 6,
  }) : assert(minLines >= 1),
       assert(maxLines >= minLines);

  /// Hard cap from `FR-CUS-029` / physical model `comment` column.
  static const int maxLength = 1000;

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? errorText;
  final String? helperText;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasError = errorText != null && errorText!.trim().isNotEmpty;

    return Padding(
      key: const Key('review-comment-field'),
      padding: EdgeInsetsDirectional.only(
        bottom: tokens.space.md - tokens.space.xs,
      ),
      child: TextFormField(
        key: const Key('review-comment-field-input'),
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        onChanged: enabled ? onChanged : null,
        enabled: enabled,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        decoration: InputDecoration(
          labelText: label,
          helperText: hasError ? null : helperText,
          errorText: hasError ? errorText : null,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
