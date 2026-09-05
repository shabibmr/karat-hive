import 'package:flutter/material.dart';

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
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? errorText;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(labelText: label, errorText: errorText),
      ),
    );
  }
}
