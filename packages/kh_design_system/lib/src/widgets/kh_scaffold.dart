import 'package:flutter/material.dart';

import 'kh_app_bar.dart';
import 'kh_pull_to_refresh.dart';

class KhScaffold extends StatelessWidget {
  const KhScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.onBack,
    this.onRefresh,
    this.lastUpdated,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final Future<void> Function()? onRefresh;
  final String? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(child: body);
    return Scaffold(
      appBar: KhAppBar(title: title, actions: actions, onBack: onBack),
      body: onRefresh == null
          ? content
          : KhPullToRefresh(
              onRefresh: onRefresh!,
              lastUpdated: lastUpdated,
              child: content,
            ),
    );
  }
}
