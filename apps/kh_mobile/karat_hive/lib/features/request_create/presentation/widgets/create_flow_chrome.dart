import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';


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

/// SH-DOM-01 — reference gold rate strip.
class GoldRateStrip extends StatelessWidget {
  const GoldRateStrip({super.key, required this.rates, this.karat});

  final GoldRateSnapshot? rates;
  final Karat? karat;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final snap = rates;
    if (snap == null) return const SizedBox.shrink();
    if (!snap.available) {
      return Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: KhInlineError(
          message: createCopy(
            context,
            'create.rateUnavailable',
            'Reference gold rates are unavailable. You can still compose this Request.',
          ),
        ),
      );
    }
    GoldRateRow? row;
    if (karat != null) {
      for (final r in snap.rates) {
        if (r.karat == karat) row = r;
      }
    }
    row ??= snap.rates.isEmpty ? null : snap.rates.first;
    final amount = double.tryParse(row?.ratePerGramAed ?? '') ?? 0;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: snap.stale ? tokens.warning : tokens.gold.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(tokens.radius.sm),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  createCopy(context, 'create.rateStrip', 'Reference gold rate'),
                ),
              ),
              MoneyDisplay(amount: amount),
              Text(createCopy(context, 'create.perGram', '/g')),
              if (snap.stale) ...[
                SizedBox(width: tokens.space.sm),
                KhStatusChip(
                  label: createCopy(context, 'create.stale', 'Stale'),
                  tone: KhStatusTone.warning,
                  compact: true,
                ),
              ],
            ],
          ),
        ),
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

List<TaxonomyNode> taxonomyLeaves(List<TaxonomyNode> nodes) {
  final leaves = <TaxonomyNode>[];
  void walk(TaxonomyNode n) {
    if (n.children.isEmpty) {
      leaves.add(n);
    } else {
      n.children.forEach(walk);
    }
  }

  nodes.forEach(walk);
  return leaves;
}
