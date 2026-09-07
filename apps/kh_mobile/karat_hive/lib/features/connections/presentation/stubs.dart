import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

class ConnectionsListScreen extends StatelessWidget {
  const ConnectionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Connections',
      body: Center(child: Text('CUS-S16')),
    );
  }
}

class ConnectionDetailScreen extends StatelessWidget {
  const ConnectionDetailScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Connection',
      body: Center(child: Text('CUS-S15 · $connectionId')),
    );
  }
}
