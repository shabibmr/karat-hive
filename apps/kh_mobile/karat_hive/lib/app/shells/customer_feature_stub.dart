import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// Tiny named stub — replace with the real CUS-Snn screen in this folder.
class CustomerFeatureStub extends StatelessWidget {
  const CustomerFeatureStub({
    super.key,
    required this.screenId,
    required this.title,
  });

  final String screenId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return KhScaffold(
      title: title,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Text('$screenId · $title', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
