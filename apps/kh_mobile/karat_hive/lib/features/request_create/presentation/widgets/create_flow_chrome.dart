import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

String createCopy(BuildContext context, String key, String fallback) {
  final value = KhStrings.of(context).s(key);
  return value == key ? fallback : value;
}

/// CU-03 — step progress + keyboard-avoiding column.
class CreateFlowChrome extends StatelessWidget {
  const CreateFlowChrome({
    super.key,
    required this.title,
    required this.stepLabel,
    required this.child,
    this.bottom,
    this.onRefresh,
  });

  final String title;
  final String stepLabel;
  final Widget child;
  final Widget? bottom;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return KhScaffold(
      title: title,
      onRefresh: onRefresh,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              tokens.space.md,
              tokens.space.sm,
              tokens.space.md,
              0,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(stepLabel, style: Theme.of(context).textTheme.labelLarge),
            ),
          ),
          Expanded(
            child: KeyboardAvoidingView(
              child: child,
            ),
          ),
          if (bottom != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(tokens.space.md),
                child: bottom,
              ),
            ),
        ],
      ),
    );
  }
}

class KeyboardAvoidingView extends StatelessWidget {
  const KeyboardAvoidingView({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: child,
    );
  }
}

class DraftActions extends StatelessWidget {
  const DraftActions({
    super.key,
    required this.busy,
    required this.onSaveDraft,
    required this.onContinue,
    this.continueLabel,
    this.continueEnabled = true,
  });

  final bool busy;
  final VoidCallback onSaveDraft;
  final VoidCallback onContinue;
  final String? continueLabel;
  final bool continueEnabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        KhButton(
          label: createCopy(context, 'create.continue', 'Continue'),
          busy: busy,
          onPressed: continueEnabled && !busy ? onContinue : null,
        ),
        // Temporarily hidden on all create screens — do not delete; restore by
        // setting visible: true.
        Visibility(
          visible: false,
          child: Column(
            children: [
              SizedBox(height: tokens.space.sm),
              KhButton(
                secondary: true,
                label: createCopy(context, 'create.saveDraft', 'Save draft'),
                busy: busy,
                onPressed: busy ? null : onSaveDraft,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
