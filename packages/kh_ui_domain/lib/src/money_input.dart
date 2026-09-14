import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// SH-DOM-04 — AED money input with optional min/max validation.
class MoneyInput extends StatelessWidget {
  const MoneyInput({
    super.key,
    required this.label,
    this.unit = 'AED',
    this.min,
    this.max,
    this.controller,
    this.onChanged,
    this.errorText,
    this.rangeErrorText,
    this.initialValue,
  });

  final String label;
  final String unit;
  final double? min;
  final double? max;
  final TextEditingController? controller;
  final ValueChanged<double?>? onChanged;
  final String? errorText;
  final String? rangeErrorText;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return KhNumericField(
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
    );
  }
}
