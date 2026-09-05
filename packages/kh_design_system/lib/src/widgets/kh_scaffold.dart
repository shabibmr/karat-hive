import 'package:flutter/material.dart';

class KhScaffold extends StatelessWidget {
  const KhScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.onRefresh,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(child: body);
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: onRefresh == null
          ? content
          : RefreshIndicator(onRefresh: onRefresh!, child: content),
    );
  }
}
