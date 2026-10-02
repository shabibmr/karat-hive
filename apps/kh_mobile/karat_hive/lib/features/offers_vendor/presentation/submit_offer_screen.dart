import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/di.dart';
import '../controller/submit_offer_controller.dart';

/// VEN-S09 — Submit Offer against a matched Request.
class SubmitOfferScreen extends ConsumerWidget {
  const SubmitOfferScreen({super.key, required this.requestId});

  final String requestId;

  Future<void> _pick(WidgetRef ref) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
    );
    if (files.isEmpty) return;
    final controller = ref.read(submitOfferControllerProvider(requestId).notifier);
    for (final f in files) {
      final path = kIsWeb ? null : f.path;
      Uint8List data = await f.readAsBytes();
      if (data.isEmpty && path != null) {
        data = Uint8List.fromList(await File(path).readAsBytes());
      }
      if (data.isEmpty) continue;
      final name = f.name.isNotEmpty
          ? f.name
          : (path?.split(RegExp(r'[/\\]')).last ?? 'photo.jpg');
      final ext = name.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      await controller.addPickedImage(
        bytes: data,
        filename: name,
        contentType: contentType,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(submitOfferControllerProvider(requestId));
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final clock = ref.watch(serverClockProvider);

    ref.listen(submitOfferControllerProvider(requestId), (prev, next) {
      if (next is SubmitOfferSucceeded && context.mounted) {
        context.go('/vendor/offers');
      }
    });

    return KhDiscardGuard(
      isDirty: state is SubmitOfferReady && state.touched,
      child: Scaffold(
        key: const Key('submit-offer-screen'),
        appBar: AppBar(title: Text(l10n?.submitOfferTitle ?? 'Submit Offer')),
        body: switch (state) {
          SubmitOfferLoading() || SubmitOfferSucceeded() => const Center(
            child: CircularProgressIndicator(),
          ),
          SubmitOfferFailed(:final failure) => KhErrorView(
            message:
                failure.message ??
                (l10n?.couldNotLoadRequest ?? 'Could not load request.'),
            onRetry: () =>
                ref.invalidate(submitOfferControllerProvider(requestId)),
          ),
          SubmitOfferReady(
            :final request,
            :final draft,
            :final submitting,
            :final failure,
            :final images,
          ) =>
            ListView(
              padding: EdgeInsets.all(tokens.space.md),
              children: [
                Text(
                  request.displayTitle(
                    fallback: l10n?.requestFallback ?? 'Request',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: tokens.space.xs),
                Text(
                  request.customer.displayPseudonym,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: tokens.space.lg),
                OfferTermsForm(
                  draft: draft,
                  requestExpiresAt: request.expiresAt,
                  now: clock.now(),
                  onChanged: () => ref
                      .read(submitOfferControllerProvider(requestId).notifier)
                      .touch(),
                  showMediaHint: false,
                  mediaSlot: SubmitOfferController.mediaAllowedForRequestType(
                          request.requestType)
                      ? _OfferImagesSlot(
                          images: images,
                          enabled: !submitting &&
                              images.length < SubmitOfferController.maxImages,
                          onAdd: () => _pick(ref),
                          onRemove: (key) => ref
                              .read(submitOfferControllerProvider(requestId)
                                  .notifier)
                              .removeImage(key),
                          onRetry: (key) => ref
                              .read(submitOfferControllerProvider(requestId)
                                  .notifier)
                              .retryImage(key),
                        )
                      : null,
                ),
                if (failure != null) ...[
                  SizedBox(height: tokens.space.md),
                  KhInlineError(
                    message: failure.message ?? failure.code ?? 'Error',
                  ),
                ],
                SizedBox(height: tokens.space.lg),
                KhButton(
                  key: const Key('submit-offer-button'),
                  label: submitting
                      ? (l10n?.commonSubmitting ?? 'Submitting…')
                      : (l10n?.submitOfferAction ?? 'Submit Offer'),
                  onPressed: submitting
                      ? null
                      : () => ref
                            .read(
                              submitOfferControllerProvider(requestId).notifier,
                            )
                            .submit(),
                ),
              ],
            ),
        },
      ),
    );
  }
}

class _OfferImagesSlot extends StatelessWidget {
  const _OfferImagesSlot({
    required this.images,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onRetry,
  });

  final List<OfferImageSlot> images;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'At least 1 image is required (up to 3 images).',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: tokens.ink.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: tokens.space.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final image in images)
              _OfferImageTile(
                slot: image,
                onRemove: () => onRemove(image.key),
                onRetry: image.failure == null ? null : () => onRetry(image.key),
              ),
            if (enabled)
              ActionChip(
                key: const Key('offer-image-add'),
                avatar: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: Text(l10n?.uploadActionAdd ?? 'Add'),
                onPressed: onAdd,
              ),
          ],
        ),
      ],
    );
  }
}

class _OfferImageTile extends StatelessWidget {
  const _OfferImageTile({
    required this.slot,
    required this.onRemove,
    this.onRetry,
  });

  final OfferImageSlot slot;
  final VoidCallback onRemove;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bytes = slot.localBytes;
    return SizedBox(
      key: Key('offer-image-${slot.key}'),
      width: 72,
      height: 72,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (bytes != null && bytes.isNotEmpty)
              Image.memory(
                bytes,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Center(child: Icon(Icons.broken_image_outlined)),
              )
            else
              const ColoredBox(
                color: Color(0x11000000),
                child: Center(child: Icon(Icons.image_outlined)),
              ),
            if (slot.uploading)
              const ColoredBox(
                color: Color(0x66000000),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (slot.failure != null)
              ColoredBox(
                color: const Color(0x99000000),
                child: Center(
                  child: IconButton(
                    key: Key('offer-retry-image-${slot.key}'),
                    padding: EdgeInsets.zero,
                    tooltip: slot.failure?.message ?? 'Retry',
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
              ),
            PositionedDirectional(
              top: 2,
              end: 2,
              child: IconButton(
                key: Key('offer-remove-image-${slot.key}'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xCC000000),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
