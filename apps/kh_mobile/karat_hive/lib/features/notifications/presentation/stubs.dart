import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// CUS-S19 — Customer alerts tab (list UI later).
class NotificationCentreScreen extends StatelessWidget {
  const NotificationCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Alerts',
      body: Center(child: Text('CUS-S19')),
    );
  }
}
