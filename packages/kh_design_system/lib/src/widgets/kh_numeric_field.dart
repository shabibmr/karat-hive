import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kh_text_field.dart';

/// SH-FND-03 — numeric field with decimal places, min/max, unit suffix.
class KhNumericField extends StatefulWidget {
  const KhNumericField({
    super.key,
    required this.label,
    this.unit,
    this.decimalPlaces = 2,
    this.min,
    this.max,
    this.controller,
    this.onChanged,
    this.errorText,
    this.rangeErrorText,
    this.initialValue,
  });

  final String label;
  final String? unit;
  final int decimalPlaces;
  final double? min;
  final double? max;
  final TextEditingController? controller;
  final ValueChanged<double?>? onChanged;
  final String? errorText;
  final String? rangeErrorText;
  final String? initialValue;

  @override
  State<KhNumericField> createState() => _KhNumericFieldState();
}

class _KhNumericFieldState extends State<KhNumericField> {
  bool _outOfRange = false;

  bool _isOutOfRange(double? value) {
    if (value == null) return false;
    if (widget.min != null && value < widget.min!) return true;
    if (widget.max != null && value > widget.max!) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final pattern = widget.decimalPlaces <= 0
        ? r'^\d*'
        : '^\\d*\\.?\\d{0,${widget.decimalPlaces}}';
    final rangeError =
        _outOfRange ? widget.rangeErrorText : null;
    return Semantics(
      textField: true,
      label: widget.unit == null ? widget.label : '${widget.label} ${widget.unit}',
      child: KhTextField(
        label: widget.label,
        controller: widget.controller,
        initialValue: widget.initialValue,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        suffixText: widget.unit,
        errorText: widget.errorText ?? rangeError,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(pattern))],
        onChanged: (raw) {
          final parsed = double.tryParse(raw);
          final out = _isOutOfRange(parsed);
          if (out != _outOfRange) {
            setState(() => _outOfRange = out);
          }
          widget.onChanged?.call(parsed);
        },
      ),
    );
  }
}
