import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';
import '../../auth/controller/publish_gate.dart';
import '../../auth/presentation/oauth_publish_gate_banner.dart';
import '../../auth/presentation/widgets/google_continue_panel.dart';
import '../controller/request_create_controller.dart';
import '../controller/request_create_state.dart';
import '../pending_publish_intent.dart';
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
      context.go(AppGuards.customerHome);
      return;
    }
    final failure = ref.read(requestCreateControllerProvider).failure;
    if (failure != null && isOAuthRequired(failure) && !gate.canPublish) {
      // Stay on screen — banner shows; user verifies Google then retries.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
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
    return CreateFlowChrome(
      title: createCopy(context, 'create.reviewTitle', 'Review & publish'),
      stepLabel: createCopy(context, 'create.reviewStep', 'Step · Review'),
      bottom: Column(
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
              message: state.failure!.message ??
                  createCopy(context, 'create.publishFailed', 'Publish failed.'),
            ),
            SizedBox(height: tokens.space.sm),
          ],
          KhButton(
            key: const Key('create-publish'),
            label: createCopy(context, 'create.publish', 'Publish'),
            busy: state.busy || state.uploading,
            onPressed: state.busy || state.uploading ? null : _onPublish,
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          RequestMediaGallery(media: state.media),
          SizedBox(height: tokens.space.lg),
          Text(
            createCopy(context, 'create.reviewSummary', 'Summary'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: tokens.space.sm),
          _Row(
            label: createCopy(context, 'create.field.type', 'Type'),
            value: type?.wire ?? '—',
          ),
          if (type == null || directionForType(type) == null)
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
            onChanged: (v) => ref
                .read(requestCreateControllerProvider.notifier)
                .setNotes(v),
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
      ),
    );
  }

  void _goLoginToPublish() {
    ref
        .read(requestCreateControllerProvider.notifier)
        .markAwaitingLoginToPublish();
    context.go(AppGuards.customerOnboarding);
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
