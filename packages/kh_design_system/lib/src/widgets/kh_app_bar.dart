import 'package:flutter/material.dart';

/// SH-SHELL-02 — top app bar. Labels and actions are caller-supplied.
class KhAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KhAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: onBack == null ? null : BackButton(onPressed: onBack),
      actions: actions,
    );
  }
}
