import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../controller/abuse_controller.dart';

/// Vendor report abuse categories per VEN-S21 form option mapping.
const List<AbuseCategoryOption> kVendorReportCategories = [
  AbuseCategoryOption(
    key: 'UNRESPONSIVE',
    label: 'Unresponsive',
  ),
  AbuseCategoryOption(
    key: 'SPAM_OR_FRAUD',
    label: 'Spam or Fraud',
  ),
  AbuseCategoryOption(
    key: 'ABUSIVE_LANGUAGE',
    label: 'Abusive Language',
  ),
  AbuseCategoryOption(
    key: 'OFF_PLATFORM_SOLICITATION',
    label: 'Off-Platform Solicitation',
  ),
  AbuseCategoryOption(
    key: 'OTHER',
    label: 'Other Policy Violation',
  ),
];

/// VEN-S21 (and CUS-S22) Report Abuse Screen (`FR-VEN-030`, `FR-CUS-033`).
///
/// Embeds [AbuseReportForm] (SH-RPT-01), maps [entityType] string to [AbuseEntityType],
/// and wires submission to [abuseControllerProvider].
class ReportAbuseScreen extends ConsumerWidget {
  const ReportAbuseScreen({
    super.key,
    this.entityType,
    this.entityId,
    this.entityReference,
    this.reporterRole = UserRole.vendor,
    this.categories = kVendorAbuseCategories,
    this.onCancel,
    this.onDone,
  });

  final String? entityType;
  final String? entityId;
  final String? entityReference;
  final UserRole reporterRole;
  final List<AbuseCategoryOption>? categories;
  final VoidCallback? onCancel;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = AbuseEntityType.parse(entityType);

    return KhScaffold(
      title: 'Report Abuse',
      body: AbuseReportForm(
        entityType: type,
        entityId: entityId ?? '',
        entityReference: entityReference,
        reporterRole: reporterRole,
        categories: categories,
        onSubmit: ({required category, required description}) async {
          final res = await ref.read(abuseControllerProvider.notifier).submit(
                entityType: type,
                entityId: entityId ?? '',
                category: category,
                description: description,
              );
          return res.when(
            ok: (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted for admin moderation'),
                  ),
                );
              }
              return true;
            },
            err: (_) => false,
          );
        },
        onCancel: onCancel ??
            () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
        onDone: onDone ??
            () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
      ),
    );
  }
}

/// Vendor report abuse alias for VEN-S21.
typedef VendorReportAbuseScreen = ReportAbuseScreen;
