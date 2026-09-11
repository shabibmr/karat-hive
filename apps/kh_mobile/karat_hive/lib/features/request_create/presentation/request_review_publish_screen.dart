import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/session/session_controller.dart';
import '../../auth/presentation/widgets/google_continue_panel.dart';
import '../controller/request_create_controller.dart';
import '../pending_publish_intent.dart';

/// CUS-S09 — Review & publish. Guest Publish opens Login overlay (GL-46–48).
class RequestReviewPublishScreen extends ConsumerStatefulWidget {
  const RequestReviewPublishScreen({super.key});

  @override
  ConsumerState<RequestReviewPublishScreen> createState() =>
      _RequestReviewPublishScreenState();
}

class _RequestReviewPublishScreenState
    extends ConsumerState<RequestReviewPublishScreen> {
  final _notesField = TextEditingController();
  bool _loginOpen = false;

  @override
  void initState() {
    super.initState();
    final notes = ref.read(requestCreateControllerProvider).notes;
    _notesField.text = notes;
  }

  @override
  void dispose() {
    _notesField.dispose();
    super.dispose();
  }

  Future<void> _onPublish() async {
    final session = ref.read(sessionProvider);
    if (session is! SignedIn) {
      ref.read(pendingPublishIntentProvider.notifier).setPending();
      await _showLoginOverlay();
      return;
    }
    await ref.read(requestCreateControllerProvider.notifier).publish();
  }

  Future<void> _showLoginOverlay() async {
    if (_loginOpen || !mounted) return;
    setState(() => _loginOpen = true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  KhL10n.of(ctx)?.guestLogIn ?? 'Log in',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GoogleContinuePanel(
                  showBiometric: false,
                  onDismiss: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (mounted) setState(() => _loginOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestCreateControllerProvider);
    final tokens = context.tokens;

    return KhScaffold(
      key: const Key('request-review-publish'),
      title: 'Review & publish',
      body: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          Text(
            state.requestType?.name ?? 'Request',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: tokens.space.sm),
          KhTextField(
            key: const Key('review-notes-field'),
            label: 'Notes',
            controller: _notesField,
            onChanged: (v) =>
                ref.read(requestCreateControllerProvider.notifier).setNotes(v),
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space.sm),
            KhInlineError(
              message: state.failure!.message ?? 'Could not publish.',
            ),
          ],
          SizedBox(height: tokens.space.md),
          KhButton(
            key: const Key('review-publish-button'),
            label: 'Publish',
            busy: state.busy,
            onPressed: (state.busy || _loginOpen) ? null : _onPublish,
          ),
        ],
      ),
    );
  }
}
