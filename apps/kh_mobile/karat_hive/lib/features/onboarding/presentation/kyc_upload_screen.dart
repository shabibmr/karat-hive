import 'dart:io';

import 'package:file_picker/file_picker.dart';
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

/// VEN-S02 — one SH-MED-04 tile per mandatory document.
class KycUploadScreen extends ConsumerWidget {
  const KycUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final files = ref.watch(kycUploadControllerProvider);
    final controller = ref.read(kycUploadControllerProvider.notifier);

    Future<void> pick(VendorDocumentType type) async {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      final path = res?.files.single.path;
      if (path == null) return;
      final ext = path.split('.').last.toLowerCase();
      final ct = ext == 'pdf'
          ? 'application/pdf'
          : (ext == 'png' ? 'image/png' : 'image/jpeg');
      await controller.pickAndUpload(type, File(path), ct);
    }

    return KhScaffold(
      title: l10n?.onboardingUploadKyc ?? 'Upload documents',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n?.onboardingKycUploadHint ??
                'Upload your trade licence and Emirates ID for verification.',
          ),
          const SizedBox(height: 16),
          DocumentChecklist(
            present: {
              for (final type in mandatoryVendorDocuments)
                if (files[type]?.done ?? false) type,
            },
          ),
          const SizedBox(height: 16),
          for (final type in mandatoryVendorDocuments)
            DocumentUploadTile(
              label: type.label,
              state: _tileState(files[type]),
              progress: files[type]?.progress ?? 0,
              errorText: files[type]?.failure?.message,
              onPick: () => pick(type),
              addLabel: l10n?.uploadActionAdd ?? 'Add',
              replaceLabel: l10n?.uploadActionReplace ?? 'Replace',
              retryLabel: l10n?.uploadActionRetry ?? 'Retry',
            ),
          const SizedBox(height: 24),
          KhButton(
            label: l10n?.commonDone ?? 'Done',
            onPressed: controller.allMandatoryDone
                ? () async {
                    ref.invalidate(vendorMeProvider);
                    await ref.read(sessionProvider.notifier).refreshUser();
                    if (context.mounted) context.go(AppGuards.awaiting);
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
