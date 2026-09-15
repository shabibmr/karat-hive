import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart' as uid;

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
    this.rateStrip,
    this.bottom,
    this.onRefresh,
  });

  final String title;
  final String stepLabel;
  final Widget child;
  final Widget? rateStrip;
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
          if (rateStrip != null) rateStrip!,
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

/// SH-DOM-01 — thin l10n wrapper over package `uid.GoldRateStrip`.
class GoldRateStrip extends StatelessWidget {
  const GoldRateStrip({super.key, required this.rates, this.karat});

  final GoldRateSnapshot? rates;
  final Karat? karat;

  @override
  Widget build(BuildContext context) {
    return uid.GoldRateStrip(
      rates: rates,
      karat: karat,
      title: createCopy(context, 'create.rateStrip', 'Reference gold rate'),
      perGramLabel: createCopy(context, 'create.perGram', '/g'),
      staleLabel: createCopy(context, 'create.stale', 'Stale'),
      unavailableMessage: createCopy(
        context,
        'create.rateUnavailable',
        'Reference gold rates are unavailable. You can still compose this Request.',
      ),
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
        SizedBox(height: tokens.space.sm),
        KhButton(
          secondary: true,
          label: createCopy(context, 'create.saveDraft', 'Save draft'),
          busy: busy,
          onPressed: busy ? null : onSaveDraft,
        ),
      ],
    );
  }
}
