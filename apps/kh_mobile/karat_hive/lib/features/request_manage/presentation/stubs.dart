import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Home',
      body: Center(child: Text('CUS-S02')),
    );
  }
}

class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Request',
      body: Center(child: Text('CUS-S10 · $requestId')),
    );
  }
}

class RequestHistoryScreen extends StatelessWidget {
  const RequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'History',
      body: Center(child: Text('CUS-S17')),
    );
  }
}
