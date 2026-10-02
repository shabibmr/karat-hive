import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';


import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';
import '../../auth/controller/publish_gate.dart';
import '../../auth/presentation/oauth_publish_gate_banner.dart';
import '../../auth/presentation/widgets/google_continue_panel.dart';
import '../controller/request_create_controller.dart';
import '../controller/request_create_state.dart';
import '../pending_publish_intent.dart';
import '../routes.dart';
import 'widgets/create_flow_chrome.dart';
import 'widgets/request_images_section.dart';


/// CUS-S09 — review & publish. Guest Publish → login → auto-publish (`adr/0011`).
class RequestReviewPublishScreen extends ConsumerStatefulWidget {
  const RequestReviewPublishScreen({super.key});

  @override
  ConsumerState<RequestReviewPublishScreen> createState() =>
      _RequestReviewPublishScreenState();
}

class _RequestReviewPublishScreenState
    extends ConsumerState<RequestReviewPublishScreen> {
  var _handledReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(requestCreateControllerProvider.notifier).ensureLoaded();
      ref
          .read(requestCreateControllerProvider.notifier)
          .goTo(RequestCreateStep.review);
      _maybeAutoPublishAfterLogin();
      // Guest reaching review (GL-57): snapshot the draft so it survives a
      // cold restart while a sign-in is pending.
      if (ref.read(sessionProvider) is! SignedIn) {
        unawaited(
          ref.read(requestCreateControllerProvider.notifier).persistPendingDraft(),
        );
      }
      _maybeReconcilePendingOverlayIntent();
    });
  }

  Future<void> _maybeAutoPublishAfterLogin() async {
    if (_handledReturn) return;
    final create = ref.read(requestCreateControllerProvider);
    if (!create.awaitingLoginToPublish) return;
    final session = ref.read(sessionProvider);
    if (session is! SignedIn) return;
    _handledReturn = true;

    if (session.isVendor) {
      ref.read(requestCreateControllerProvider.notifier).resetFlow();
      if (mounted) context.go(AppGuards.homeFor(session));
      return;
    }

    final ok = await ref
        .read(requestCreateControllerProvider.notifier)
        .onSessionReadyForPublish();
    if (!mounted) return;
    if (ok) {
      ref.read(requestCreateControllerProvider.notifier).resetFlow();
      context.go(AppGuards.customerHome);
    }
  }

  bool _overlaySheetOpen = false;

  Future<void> _showGuestSignInOverlay() async {
    _overlaySheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: GoogleContinuePanel(
          onDismiss: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
    _overlaySheetOpen = false;
  }

  /// GL-57…GL-60: reconcile a pending overlay-driven publish intent once the
  /// Guest signs in, closing the overlay (if still open) and routing to the
  /// newly-published Request's detail screen.
  Future<void> _maybeReconcilePendingOverlayIntent() async {
    if (!ref.read(pendingPublishIntentProvider)) return;
    final session = ref.read(sessionProvider);
    if (session is! SignedIn) return;

    if (_overlaySheetOpen && mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    final ok = await ref
        .read(requestCreateControllerProvider.notifier)
        .reconcilePendingPublish();
    if (!mounted) return;
    if (ok) {
      final published = ref.read(requestCreateControllerProvider).published;
      ref.read(requestCreateControllerProvider.notifier).resetFlow();
      if (published != null) {
        context.go('${AppGuards.customerRequests}/${published.id}');
      } else {
        context.go(AppGuards.customerHome);
      }
    }
  }

  Future<void> _onPublish() async {
    final session = ref.read(sessionProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);

    if (session is! SignedIn) {
      ref.read(pendingPublishIntentProvider.notifier).setPending();
      unawaited(controller.persistPendingDraft());
      await _showGuestSignInOverlay();
      return;
    }

    if (session.isVendor) {
      controller.resetFlow();
      if (mounted) context.go(AppGuards.homeFor(session));
      return;
    }

    final gate = ref.read(publishGateProvider);
    final ok = await controller.publish();
    if (!mounted) return;
    if (ok) {
      controller.resetFlow();
      context.go(AppGuards.customerHome);
      return;
    }
    final failure = ref.read(requestCreateControllerProvider).failure;
    if (failure != null && isOAuthRequired(failure) && !gate.canPublish) {
      // Stay on screen — banner shows; user verifies Google then retries.
    }
  }

  Future<void> _onSaveDraft() async {
    final session = ref.read(sessionProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);

    if (session is! SignedIn) {
      ref.read(pendingPublishIntentProvider.notifier).setPending();
      unawaited(controller.persistPendingDraft());
      await _showGuestSignInOverlay();
      return;
    }

    final ok = await controller.saveDraft();
    if (!mounted) return;
    if (ok) {
      controller.resetFlow();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createCopy(context, 'create.draftSaved', 'Draft saved'),
          ),
        ),
      );
      context.go('${AppGuards.customerRequests}?tab=DRAFTS');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);
    final session = ref.watch(sessionProvider);
    final gate = ref.watch(publishGateProvider);
    final showOauthBanner = session is SignedIn &&
        session.isCustomer &&
        (!gate.canPublish ||
            (state.failure != null && isOAuthRequired(state.failure!)));

    // Returning from login while this screen is rebuilt.
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next is SignedIn &&
          state.awaitingLoginToPublish &&
          !_handledReturn) {
        _maybeAutoPublishAfterLogin();
      }
      if (next is SignedIn && ref.read(pendingPublishIntentProvider)) {
        _maybeReconcilePendingOverlayIntent();
      }
    });

    if (state.step == RequestCreateStep.success) {
      return KhScaffold(
        title: createCopy(context, 'create.publishedTitle', 'Published'),
        body: KhEmptyView(
          icon: Icons.check_circle_outline,
          message: createCopy(
            context,
            'create.publishedBody',
            'Your request is live. Jewellers can now send offers.',
          ),
        ),
      );
    }

    final type = state.requestType;
    final isFind = type == RequestType.findOrnament;
    final publishBusy = state.busy || state.uploading;
    final publishEnabled = !publishBusy &&
        !(session is SignedIn && !controller.canContinuePhotos);

    return CreateFlowChrome(
      title: isFind
          ? createCopy(context, 'service.card.ornament', 'Find An Ornament')
          : createCopy(context, 'create.reviewTitle', 'Review & publish'),
      eyebrow: isFind
          ? createCopy(context, 'create.reviewEyebrow', 'REVIEW YOUR REQUEST')
          : null,
      stepLabel: isFind
          ? ''
          : createCopy(context, 'create.reviewStep', 'Step · Review'),
      bottom: Container(
        color: tokens.formSurface,
        padding: EdgeInsets.fromLTRB(
          tokens.space.md,
          tokens.space.sm,
          tokens.space.md,
          tokens.space.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showOauthBanner)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.space.md),
                child: OAuthPublishGateBanner(
                  busy: state.busy,
                  message: state.failure != null && isOAuthRequired(state.failure!)
                      ? state.failure!.message
                      : null,
                  onVerify: _goLoginToPublish,
                ),
              ),
            if (state.failure != null && !isOAuthRequired(state.failure!)) ...[
              KhInlineError(
                message: state.failure!.fieldErrors.isNotEmpty
                    ? state.failure!.fieldErrors.values.join('\n')
                    : (state.failure!.message ??
                        createCopy(context, 'create.publishFailed', 'Publish failed.')),
              ),
              SizedBox(height: tokens.space.sm),
            ],
            KhButton(
              key: const Key('create-publish'),
              label: isFind
                  ? createCopy(context, 'create.publishRequest', 'Publish Request')
                  : createCopy(context, 'create.publish', 'Publish'),
              busy: publishBusy,
              onPressed: publishEnabled ? _onPublish : null,
            ),
            if (!isFind) ...[
              SizedBox(height: tokens.space.sm),
              TextButton(
                key: const Key('create-save-draft'),
                onPressed: publishBusy ? null : _onSaveDraft,
                child: Text(
                  createCopy(context, 'create.saveDraft', 'Save draft'),
                ),
              ),
            ],
          ],
        ),
      ),
      child: isFind
          ? _FindOrnamentReviewBody(
              state: state,
              onEdit: () => _editFindCompose(context, type!),
            )
          : _GenericReviewBody(
              state: state,
              type: type,
              onNotesChanged: (v) =>
                  ref.read(requestCreateControllerProvider.notifier).setNotes(v),
            ),
    );
  }

  void _editFindCompose(BuildContext context, RequestType type) {
    ref.read(requestCreateControllerProvider.notifier).goTo(RequestCreateStep.compose);
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(RequestCreatePaths.composeFor(type));
  }

  void _goLoginToPublish() {
    ref
        .read(requestCreateControllerProvider.notifier)
        .markAwaitingLoginToPublish();
    context.go(AppGuards.customerOnboarding);
  }
}

class _FindOrnamentReviewBody extends StatelessWidget {
  const _FindOrnamentReviewBody({
    required this.state,
    required this.onEdit,
  });

  final RequestCreateState state;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final rows = <_IconReviewRowData>[
      if (state.ornamentType != null)
        _IconReviewRowData(
          icon: Icons.diamond_outlined,
          label: createCopy(context, 'create.row.type', 'TYPE'),
          value: _ornamentDisplayName(context, state.ornamentType!),
        ),
      if (state.weightGrams != null && state.weightGrams!.trim().isNotEmpty)
        _IconReviewRowData(
          icon: Icons.scale_outlined,
          label: createCopy(context, 'create.row.weight', 'WEIGHT'),
          value: _weightDisplay(context, state),
        ),
      if (state.purityKarat != null && state.purityKarat != Karat.unknown)
        _IconReviewRowData(
          icon: Icons.verified_outlined,
          label: createCopy(context, 'create.row.purity', 'PURITY'),
          value: createCopy(context, 'create.purityKaratLabel', '{n} Karat')
              .replaceAll('{n}', state.purityKarat!.wire.replaceAll('K', '')),
        ),
      if (state.budgetMax != null && state.budgetMax!.trim().isNotEmpty)
        _IconReviewRowData(
          icon: Icons.account_balance_wallet_outlined,
          label: createCopy(context, 'create.row.budget', 'BUDGET'),
          value: createCopy(context, 'create.budgetUpTo', 'Up to AED {n}')
              .replaceAll('{n}', state.budgetMax!.trim()),
        ),
      if (state.notes.trim().isNotEmpty)
        _IconReviewRowData(
          key: const Key('review-notes-row'),
          icon: Icons.notes_outlined,
          label: createCopy(context, 'create.row.notes', 'NOTES'),
          value: state.notes.trim(),
        ),

    ];

    return ListView(
      padding: EdgeInsets.all(tokens.space.md),
      children: [
        if (state.imagesAllowed) ...[
          RequestReviewMosaic(
            media: state.media,
            maxImages: state.maxImages,
          ),
          SizedBox(height: tokens.space.lg),
        ],
        for (var i = 0; i < rows.length; i++) ...[
          _IconReviewRow(data: rows[i]),
          if (i < rows.length - 1)
            Divider(height: 1, color: tokens.inkHairline),
        ],
        SizedBox(height: tokens.space.md),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            key: const Key('review-edit'),
            onPressed: onEdit,
            child: Text(createCopy(context, 'create.edit', 'Edit')),
          ),
        ),
        SizedBox(height: tokens.space.sm),
        Text(
          createCopy(
            context,
            'create.publishHint',
            'Publishing makes this request visible to matched jewellers for 48 hours.',
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.inkSecondary,
              ),
        ),
      ],
    );
  }
}

class _GenericReviewBody extends StatelessWidget {
  const _GenericReviewBody({
    required this.state,
    required this.type,
    required this.onNotesChanged,
  });

  final RequestCreateState state;
  final RequestType? type;
  final ValueChanged<String> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final requestType = type;
    final showDirection =
        requestType == null || directionForType(requestType) == null;
    return ListView(
      padding: EdgeInsets.all(tokens.space.md),
      children: [
        if (state.imagesAllowed) ...[
          RequestMediaGallery(media: state.media),
          SizedBox(height: tokens.space.lg),
        ],
        Text(
          createCopy(context, 'create.reviewSummary', 'Summary'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: tokens.space.sm),
        _Row(
          label: createCopy(context, 'create.field.type', 'Type'),
          value: requestType?.wire ?? '—',
        ),
        if (showDirection)
          _Row(
            label: createCopy(context, 'create.field.direction', 'Direction'),
            value: state.direction?.wire ?? '—',
          ),


        if (state.ornamentType != null)
          _Row(
            label: createCopy(context, 'create.ornamentType', 'Ornament type'),
            value: ornamentWire(state.ornamentType!),
          ),
        if (state.purityKarat != null)
          _Row(
            label: createCopy(context, 'create.purity', 'Purity'),
            value: state.purityKarat!.wire,
          ),
        if (state.weightGrams != null)
          _Row(
            label: createCopy(context, 'create.field.weight', 'Weight (g)'),
            value: state.weightGrams!,
          ),
        if (state.budgetMax != null)
          _Row(
            label: createCopy(context, 'create.field.budget', 'Budget (AED)'),
            value: state.budgetMax!,
          ),
        SizedBox(height: tokens.space.sm),
        KhTextField(
          key: const Key('review-notes-field'),
          label: createCopy(context, 'create.field.notes', 'Notes'),
          initialValue: state.notes,
          maxLines: 3,
          onChanged: onNotesChanged,
        ),
        SizedBox(height: tokens.space.md),
        Text(
          createCopy(
            context,
            'create.publishHint',
            'Publishing makes this request visible to matched jewellers for 48 hours.',
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _IconReviewRowData {
  const _IconReviewRowData({
    this.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final Key? key;
  final IconData icon;
  final String label;
  final String value;
}

class _IconReviewRow extends StatelessWidget {
  const _IconReviewRow({required this.data});

  final _IconReviewRowData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fonts = KhFonts.forLocale(Localizations.maybeLocaleOf(context));
    return Padding(
      key: data.key,
      padding: EdgeInsets.symmetric(vertical: tokens.space.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 22, color: tokens.gold),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fonts.isArabic ? data.label : data.label.toUpperCase(),
                  style: fonts
                      .sansStyle(10, FontWeight.w600, trackingEm: 0.10)
                      .copyWith(color: tokens.inkSecondary),
                ),
                SizedBox(height: tokens.space.xs),
                Text(
                  data.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: tokens.ink,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _ornamentDisplayName(BuildContext context, OrnamentType t) =>
    switch (t) {
      OrnamentType.ring => createCopy(context, 'create.ornament.ring', 'Ring'),
      OrnamentType.necklace =>
        createCopy(context, 'create.ornament.necklace', 'Necklace'),
      OrnamentType.bracelet =>
        createCopy(context, 'create.ornament.bracelet', 'Bracelet'),
      OrnamentType.bangle =>
        createCopy(context, 'create.ornament.bangle', 'Bangle'),
      OrnamentType.earring =>
        createCopy(context, 'create.ornament.earring', 'Earrings'),
      OrnamentType.pendant =>
        createCopy(context, 'create.ornament.pendant', 'Pendant'),
      OrnamentType.chain => createCopy(context, 'create.ornament.chain', 'Chain'),
      OrnamentType.other => createCopy(context, 'create.ornament.other', 'Other'),
      OrnamentType.unknown => '—',
    };

String _weightDisplay(BuildContext context, RequestCreateState state) {
  final grams = state.weightGrams!.trim();
  final key = state.weightIsApproximate
      ? 'create.weightApproxValue'
      : 'create.weightExactValue';
  final fallback =
      state.weightIsApproximate ? 'Approx. {n} grams' : '{n} grams';
  return createCopy(context, key, fallback).replaceAll('{n}', grams);
}
