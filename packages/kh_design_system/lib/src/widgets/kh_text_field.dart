import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

class KhTextField extends StatelessWidget {
  const KhTextField({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscure = false,
    this.errorText,
    this.initialValue,
    this.suffixText,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? errorText;
  final String? initialValue;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: tokens.space.md - tokens.space.xs),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscure,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixText: suffixText,
        ),
      ),
    );
  }
}
