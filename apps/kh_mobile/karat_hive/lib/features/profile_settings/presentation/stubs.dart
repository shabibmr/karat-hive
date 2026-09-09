import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Profile',
      body: Center(child: Text('CUS-S20')),
    );
  }
}

class CustomerSettingsScreen extends StatelessWidget {
  const CustomerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Settings',
      body: Center(child: Text('CUS-S21')),
    );
  }
}

/// Deep-link target for `/vendor/profile/documents` until VEN-S15 (CP6-B02).
class VendorProfileDocumentsStub extends StatelessWidget {
  const VendorProfileDocumentsStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Documents',
      body: Center(
        child: Text('Document management lands with VEN-S15 (CP6-B02).'),
      ),
    );
  }
}
