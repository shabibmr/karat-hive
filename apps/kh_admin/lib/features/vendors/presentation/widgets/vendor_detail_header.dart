import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// "Back to Vendors" button. Was `_VendorDetailScreenState._buildBackButton`
/// (TR-S2-10).
class VendorDetailBackButton extends StatelessWidget {
  const VendorDetailBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return TextButton.icon(
      key: const Key('vendor-detail-back-button'),
      onPressed: () => context.go('/vendors'),
      icon: const Icon(Icons.arrow_back, size: 18),
      label: const Text('Back to Vendors'),
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

/// Screen header with verification + account state chips. Was
/// `_VendorDetailScreenState._buildHeader` (TR-S2-10).
class VendorDetailHeader extends StatelessWidget {
  const VendorDetailHeader({super.key, required this.detail});

  final VendorDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return KhScreenHeader(
      eyebrow: detail.tradingName != null && detail.tradingName!.isNotEmpty
          ? '${detail.tradingName!.toUpperCase()} · ${detail.id}'
          : 'VENDOR ID: ${detail.id}',
      heading: detail.legalBusinessName,
      supportingText: 'Registered business profile & admin lifecycle controls',
      trailing: Wrap(
        spacing: kh.spacing.xs,
        runSpacing: kh.spacing.xs,
        children: [
          KhStatusChip(
            label: vendorVerificationLabel(l10n, detail.verificationState),
            tone: vendorVerificationTone(detail.verificationState),
          ),
          KhStatusChip(
            label: vendorAccountLabel(l10n, detail.accountState),
            tone: vendorAccountTone(detail.accountState),
          ),
        ],
      ),
    );
  }
}

String vendorVerificationLabel(
    AppLocalizations? l10n, VendorVerificationState state) {
  switch (state) {
    case VendorVerificationState.registered:
      return l10n?.vendorsVerificationRegistered ?? 'REGISTERED';
    case VendorVerificationState.pendingVerification:
      return l10n?.vendorsVerificationPending ?? 'PENDING VERIFICATION';
    case VendorVerificationState.verified:
      return l10n?.vendorsVerificationVerified ?? 'VERIFIED';
    case VendorVerificationState.rejected:
      return l10n?.vendorsVerificationRejected ?? 'REJECTED';
  }
}

String vendorAccountLabel(AppLocalizations? l10n, VendorAccountState state) {
  switch (state) {
    case VendorAccountState.active:
      return l10n?.vendorsAccountActive ?? 'ACTIVE';
    case VendorAccountState.suspended:
      return l10n?.vendorsAccountSuspended ?? 'SUSPENDED';
    case VendorAccountState.deactivated:
      return l10n?.vendorsAccountDeactivated ?? 'DEACTIVATED';
  }
}

KhStatusTone vendorVerificationTone(VendorVerificationState state) {
  switch (state) {
    case VendorVerificationState.verified:
      return KhStatusTone.success;
    case VendorVerificationState.pendingVerification:
      return KhStatusTone.pending;
    case VendorVerificationState.rejected:
      return KhStatusTone.error;
    case VendorVerificationState.registered:
      return KhStatusTone.neutral;
  }
}

KhStatusTone vendorAccountTone(VendorAccountState state) {
  switch (state) {
    case VendorAccountState.active:
      return KhStatusTone.success;
    case VendorAccountState.suspended:
      return KhStatusTone.pending;
    case VendorAccountState.deactivated:
      return KhStatusTone.error;
  }
}
