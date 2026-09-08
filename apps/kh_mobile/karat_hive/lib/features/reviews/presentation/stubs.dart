import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

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
