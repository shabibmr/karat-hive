import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// SH-DOM-05 — weight input in grams (0.10–5000.00, 2 dp) with approximate flag.
class WeightInput extends StatelessWidget {
  const WeightInput({
    super.key,
    required this.label,
    this.unit = 'g',
    this.min = 0.10,
    this.max = 5000.00,
    this.controller,
    this.onChanged,
    this.errorText,
    this.rangeErrorText,
    this.initialValue,
    this.approximate = false,
    this.onApproximateChanged,
    this.approximateLabel = 'Weight is approximate',
  });

  final String label;
  final String unit;
  final double min;
  final double max;
  final TextEditingController? controller;
  final ValueChanged<double?>? onChanged;
  final String? errorText;
  final String? rangeErrorText;
  final String? initialValue;
  final bool approximate;
  final ValueChanged<bool>? onApproximateChanged;
  final String approximateLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KhNumericField(
          label: label,
          unit: unit,
          decimalPlaces: 2,
          min: min,
          max: max,
          controller: controller,
          onChanged: onChanged,
          errorText: errorText,
          rangeErrorText: rangeErrorText,
          initialValue: initialValue,
        ),
        if (onApproximateChanged != null) ...[
          SizedBox(height: tokens.space.xs),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: approximate,
            onChanged: (v) => onApproximateChanged!(v ?? false),
            title: Text(approximateLabel),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ],
    );
  }
}
