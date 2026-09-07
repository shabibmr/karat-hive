import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/di.dart';
import '../controller/submit_offer_controller.dart';

/// VEN-S09 — Submit Offer against a matched Request.
class SubmitOfferScreen extends ConsumerWidget {
  const SubmitOfferScreen({super.key, required this.requestId});

  final String requestId;

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

    return Scaffold(
      key: const Key('submit-offer-screen'),
      appBar: AppBar(
        title: Text(l10n?.submitOfferTitle ?? 'Submit Offer'),
      ),
      body: switch (state) {
        SubmitOfferLoading() || SubmitOfferSucceeded() =>
          const Center(child: CircularProgressIndicator()),
        SubmitOfferFailed(:final failure) => KhErrorView(
            message: failure.message ??
                (l10n?.couldNotLoadRequest ?? 'Could not load request.'),
            onRetry: () =>
                ref.invalidate(submitOfferControllerProvider(requestId)),
          ),
        SubmitOfferReady(
          :final request,
          :final config,
          :final draft,
          :final submitting,
          :final failure,
          :final uploadedKeys,
        ) =>
          ListView(
            padding: EdgeInsets.all(tokens.space.md),
            children: [
              Text(
                request.reference ??
                    request.categoryName ??
                    (l10n?.requestFallback ?? 'Request'),
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
                validityOptions: config.offerValidityHours,
                requestExpiresAt: request.expiresAt,
                now: clock.now(),
                onChanged: () => ref
                    .read(submitOfferControllerProvider(requestId).notifier)
                    .touch(),
                mediaSlot: _OfferImagesSlot(
                  keys: uploadedKeys,
                  enabled: !submitting && draft.mediaKeys.length < 3,
                  onAdd: () async {
                    final res = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const ['jpg', 'jpeg', 'png'],
                    );
                    final path = res?.files.single.path;
                    if (path == null) return;
                    final ext = path.split('.').last.toLowerCase();
                    final ct = ext == 'png' ? 'image/png' : 'image/jpeg';
                    await ref
                        .read(submitOfferControllerProvider(requestId).notifier)
                        .addImage(File(path), ct);
                  },
                  onRemove: (key) => ref
                      .read(submitOfferControllerProvider(requestId).notifier)
                      .removeImage(key),
                ),
              ),
              if (failure != null) ...[
                SizedBox(height: tokens.space.md),
                KhInlineError(message: failure.message ?? failure.code ?? 'Error'),
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
                        .read(submitOfferControllerProvider(requestId).notifier)
                        .submit(),
              ),
            ],
          ),
      },
    );
  }
}

class _OfferImagesSlot extends StatelessWidget {
  const _OfferImagesSlot({
    required this.keys,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> keys;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.offerImagesHint ?? 'Up to 3 supporting images (optional).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: tokens.space.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final key in keys)
              InputChip(
                key: Key('offer-image-$key'),
                label: Text(key.split('/').last),
                onDeleted: () => onRemove(key),
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
