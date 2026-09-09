import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// CUS-S18 — Customer leave review (form UI later).
class LeaveReviewScreen extends StatelessWidget {
  const LeaveReviewScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Review',
      body: Center(child: Text('CUS-S18 · $connectionId')),
    );
  }
}

/// VEN-S19 — Vendor leave customer feedback (form UI: CP5-B03.3).
class VendorLeaveReviewScreen extends StatelessWidget {
  const VendorLeaveReviewScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Feedback',
      body: Center(child: Text('VEN-S19 · $connectionId')),
    );
  }
}

/// VEN-S20 — My reviews & responses (list UI: CP5-B04).
class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'My reviews',
      body: Center(child: Text('VEN-S20')),
    );
  }
}
