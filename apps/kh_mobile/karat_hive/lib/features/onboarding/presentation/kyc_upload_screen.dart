import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';
import '../controller/kyc_upload_controller.dart';
import '../controller/vendor_me_controller.dart';

/// VEN-S02 — KYC verification: business licence details + document uploads.
class KycUploadScreen extends ConsumerStatefulWidget {
  const KycUploadScreen({super.key});

  @override
  ConsumerState<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends ConsumerState<KycUploadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kycUploadControllerProvider.notifier).prefetchDocumentIntent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(kycUploadControllerProvider);
    final controller = ref.read(kycUploadControllerProvider.notifier);

    Future<void> pick(VendorDocumentType type) async {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );
      final file = res?.files.single;
      if (file == null) return;
      final name = file.name;
      final ext = name.split('.').last.toLowerCase();
      final ct = switch (ext) {
        'pdf' => 'application/pdf',
        'png' => 'image/png',
        _ => 'image/jpeg',
      };
      final bytes = file.bytes;
      if (bytes != null && bytes.isNotEmpty) {
        await controller.pickAndUploadBytes(type, bytes, ct);
        return;
      }
      // On web, PlatformFile.path throws — bytes are required.
      if (kIsWeb) return;
      final path = file.path;
      if (path == null) return;
      await controller.pickAndUpload(type, File(path), ct);
    }

    return KhScaffold(
      title: 'Verify your business',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.failure != null) ...[
            KhInlineError(
              message: state.failure!.message ?? 'Verification update failed.',
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Enter your official business licence details and upload required documents.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // SECTION 1: Legal & Licence Details
          Text(
            'Official Business Details',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          KhTextField(
            label: 'Registered company / Legal name *',
            initialValue: state.legalBusinessName,
            onChanged: (v) => controller.patchFields(legalBusinessName: v),
          ),
          KhTextField(
            label: 'Trade licence number *',
            initialValue: state.tradeLicenceNumber,
            onChanged: (v) => controller.patchFields(tradeLicenceNumber: v),
          ),
          KhTextField(
            label: 'Licence expiry date (YYYY-MM-DD) *',
            initialValue: state.licenceExpiryDate,
            readOnly: true,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now.add(const Duration(days: 365)),
                firstDate: now,
                lastDate: now.add(const Duration(days: 365 * 10)),
              );
              if (picked != null) {
                final formatted =
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                controller.patchFields(licenceExpiryDate: formatted);
              }
            },
            onChanged: (v) => controller.patchFields(licenceExpiryDate: v),
          ),
          const SizedBox(height: 16),

          // SECTION 2: Document Uploads
          Text(
            'Verification Documents',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          DocumentChecklist(
            present: {
              for (final type in mandatoryVendorDocuments)
                if (state.documents[type]?.done ?? false) type,
            },
          ),
          const SizedBox(height: 12),
          for (final type in mandatoryVendorDocuments)
            DocumentUploadTile(
              label: type.label,
              state: _tileState(state.documents[type]),
              progress: state.documents[type]?.progress ?? 0,
              errorText: state.documents[type]?.failure?.message,
              onPick: () => pick(type),
              addLabel: l10n?.uploadActionAdd ?? 'Add',
              replaceLabel: l10n?.uploadActionReplace ?? 'Replace',
              retryLabel: l10n?.uploadActionRetry ?? 'Retry',
            ),
          const SizedBox(height: 24),
          KhButton(
            label: 'Submit for Verification',
            busy: state.busy,
            onPressed: state.isReadyToSubmit
                ? () async {
                    final ok = await controller.submitKyc();
                    if (ok && context.mounted) {
                      ref.invalidate(vendorMeProvider);
                      await ref.read(sessionProvider.notifier).refreshUser();
                      if (context.mounted) context.go(AppGuards.awaiting);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  UploadTileState _tileState(KycFileState? f) {
    if (f == null) return UploadTileState.empty;
    if (f.uploading) return UploadTileState.uploading;
    if (f.failure != null) return UploadTileState.failed;
    if (f.done) return UploadTileState.uploaded;
    return UploadTileState.empty;
  }
}
