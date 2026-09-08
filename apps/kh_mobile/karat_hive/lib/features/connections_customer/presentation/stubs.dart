import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

class CustomerConnectionsListStubScreen extends StatelessWidget {
  const CustomerConnectionsListStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Connections',
      body: Center(child: Text('CUS-S16')),
    );
  }
}

class CustomerConnectionDetailStubScreen extends StatelessWidget {
  const CustomerConnectionDetailStubScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Connection',
      body: Center(child: Text('CUS-S15 · $connectionId')),
    );
  }
}
