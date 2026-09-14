import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// Renamed stubs — real screens live alongside this file.
class CustomerHomeStubScreen extends StatelessWidget {
  const CustomerHomeStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Home',
      body: Center(child: Text('CUS-S02')),
    );
  }
}

class OwnerRequestDetailStubScreen extends StatelessWidget {
  const OwnerRequestDetailStubScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Request',
      body: Center(child: Text('CUS-S10 · $requestId')),
    );
  }
}

class RequestHistoryStubScreen extends StatelessWidget {
  const RequestHistoryStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'History',
      body: Center(child: Text('CUS-S17')),
    );
  }
}
