import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';

/// "Back to Customers" button. Was
/// `_CustomerDetailScreenState._buildBackButton` (TR-S2-12).
class CustomerDetailBackButton extends StatelessWidget {
  const CustomerDetailBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return TextButton.icon(
      key: const Key('customer-detail-back-button'),
      onPressed: () => context.go('/customers'),
      icon: const Icon(Icons.arrow_back, size: 18),
      label: const Text('Back to Customers'),
      style: TextButton.styleFrom(
        foregroundColor: kh.colors.goldPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: kh.spacing.sm,
          vertical: kh.spacing.xs,
        ),
      ),
    );
  }
}

/// Screen header with account-state chip. Was
/// `_CustomerDetailScreenState._buildHeader` (TR-S2-12).
class CustomerDetailHeader extends StatelessWidget {
  const CustomerDetailHeader({super.key, required this.detail});

  final CustomerDetail detail;

  @override
  Widget build(BuildContext context) {
    return KhScreenHeader(
      eyebrow: 'Customer Profile',
      heading: detail.displayName.isNotEmpty
          ? detail.displayName
          : 'Customer Record',
      supportingText: 'ID: ${detail.id} • User ID: ${detail.userId}',
      trailing: KhStatusChip(
        label: detail.accountState.displayName,
        tone: customerStatusTone(detail.accountState),
      ),
    );
  }
}

KhStatusTone customerStatusTone(CustomerAccountState state) {
  switch (state) {
    case CustomerAccountState.active:
      return KhStatusTone.success;
    case CustomerAccountState.suspended:
      return KhStatusTone.pending;
    case CustomerAccountState.deactivated:
      return KhStatusTone.error;
  }
}
