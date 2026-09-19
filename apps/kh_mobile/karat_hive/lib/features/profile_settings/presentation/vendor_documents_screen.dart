import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';
import '../../onboarding/controller/vendor_me_controller.dart';
import '../controller/vendor_documents_controller.dart';

/// VEN-S15 documents deep link (`/vendor/profile/documents`, CP6-B02) —
/// re-uploads/re-submits KYC documents outside the initial onboarding flow.
/// Core business-profile fields (trading name, logo, hours, etc.) live in
/// [BusinessProfileScreen]; this screen is document-management only.
class VendorDocumentsScreen extends ConsumerWidget {
  const VendorDocumentsScreen({super.key});

  static const Key screenKey = Key('vendor-documents-screen');

  String _statusSuffix(VendorDocumentType type, VendorDocumentsState state) {
    final pending = state.pending[type];
    if (pending?.uploading ?? false) return ' · Uploading…';
    if (pending?.failure != null) return ' · Upload failed';
    final doc = state.documents[type];
    if (doc == null) return '';
    return doc.verified ? ' · Verified' : ' · Pending review';
  }

  UploadTileState _tileState(VendorDocumentType type, VendorDocumentsState state) {
    final pending = state.pending[type];
    if (pending?.uploading ?? false) return UploadTileState.uploading;
    if (pending?.failure != null) return UploadTileState.failed;
    if ((pending?.done ?? false) || state.documents.containsKey(type)) {
      return UploadTileState.uploaded;
    }
    return UploadTileState.empty;
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    VendorDocumentType type,
  ) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = res?.files.single;
    if (file == null) return;
    final ext = file.name.split('.').last.toLowerCase();
    final contentType = ext == 'pdf'
        ? 'application/pdf'
        : (ext == 'png' ? 'image/png' : 'image/jpeg');
    final controller = ref.read(vendorDocumentsControllerProvider.notifier);
    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      await controller.pickAndUploadBytes(type, bytes, contentType);
      return;
    }
    if (kIsWeb) return;
    final path = file.path;
    if (path == null) return;
    await controller.pickAndUpload(type, File(path), contentType);
  }

  Future<void> _onResubmit(BuildContext context, WidgetRef ref) async {
    final confirmed = await showKhConfirmDialog(
      context,
      title: 'Re-verification Required',
      body:
          'Submitting updated documents requires administrator re-verification. Your account will enter pending verification until reviewed.',
      destructive: true,
      confirmLabel: 'Submit for Re-verification',
      cancelLabel: 'Cancel',
    );
    if (confirmed != true || !context.mounted) return;

    final ok = await ref.read(vendorDocumentsControllerProvider.notifier).resubmit();
    if (!ok || !context.mounted) return;
    ref.invalidate(vendorMeProvider);
    await ref.read(sessionProvider.notifier).refreshUser();
    if (context.mounted) context.go(AppGuards.awaiting);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vendorDocumentsControllerProvider);

    if (state.loading) {
      return const KhScaffold(
        title: 'Documents',
        body: KhLoadingView(),
      );
    }

    return KhScaffold(
      key: screenKey,
      title: 'Documents',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Review your verification documents and submit replacements if requested by the admin team.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (state.failure != null) ...[
            KhInlineError(
              message: state.failure!.message ?? 'Could not load documents.',
            ),
            const SizedBox(height: 12),
          ],
          for (final type in mandatoryVendorDocuments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DocumentUploadTile(
                label: '${type.label}${_statusSuffix(type, state)}',
                state: _tileState(type, state),
                progress: state.pending[type]?.progress ?? 0,
                errorText: state.pending[type]?.failure?.message,
                onPick: () => _pick(context, ref, type),
              ),
            ),
          const SizedBox(height: 16),
          KhButton(
            label: 'Submit for Re-verification',
            busy: state.busy,
            onPressed: state.canResubmit ? () => _onResubmit(context, ref) : null,
          ),
        ],
      ),
    );
  }
}
