import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';
import '../../auth/controller/publish_gate.dart';
import '../../auth/presentation/oauth_publish_gate_banner.dart';
import '../controller/request_create_controller.dart';
import '../controller/request_create_state.dart';
import 'widgets/create_flow_chrome.dart';

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

  Future<void> _onPublish() async {
    final session = ref.read(sessionProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);

    if (session is! SignedIn) {
      controller.markAwaitingLoginToPublish();
      if (mounted) context.go(AppGuards.customerOnboarding);
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
          _Row(
            label: createCopy(context, 'create.field.photos', 'Photos'),
            value: '${state.media.length}',
          ),
          if (state.notes.trim().isNotEmpty)
            _Row(
              label: createCopy(context, 'create.field.notes', 'Notes'),
              value: state.notes.trim(),
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
