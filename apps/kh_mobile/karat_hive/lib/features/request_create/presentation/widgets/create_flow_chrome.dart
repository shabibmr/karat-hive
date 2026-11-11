import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../routes.dart';

String createCopy(BuildContext context, String key, String fallback) {
  final value = KhStrings.of(context).s(key);
  return value == key ? fallback : value;
}

/// At least 60. Grows with the 21px title and 10px eyebrow; 28 is the
/// header's vertical padding plus the gap between them.
double createFlowHeaderHeight(TextScaler scaler) {
  final grown = scaler.scale(21) + scaler.scale(10) + 28;
  return grown < 60 ? 60 : grown;
}

/// Top header block for CreateFlowChrome. [height] comes from
/// [createFlowHeaderHeight].
class CreateFlowHeader extends StatelessWidget implements PreferredSizeWidget {
  const CreateFlowHeader({
    super.key,
    required this.title,
    required this.height,
    this.eyebrow,
    this.onBack,
  });

  final String title;
  final double height;
  final String? eyebrow;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final locale = Localizations.maybeLocaleOf(context);
    final fonts = KhFonts.forLocale(locale);
    // Scaffold pins this bar to the top of the window. Pad by the status-bar
    // inset so the back control and title are not drawn under it. When
    // [KhSystemInset] has already consumed that inset, this padding is zero.
    final topInset = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.only(top: topInset),
      child: Container(
        height: height,
        color: tokens.formSurface,
        padding: EdgeInsets.symmetric(horizontal: tokens.space.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: tokens.inkBorderSoft, width: 1),
              ),
              child: IconButton(
                key: const Key('create-flow-back'),
                padding: EdgeInsets.zero,
                iconSize: 20,
                style: IconButton.styleFrom(
                  fixedSize: const Size(36, 36),
                  minimumSize: const Size(36, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.arrow_back),
                color: tokens.ink,
                onPressed: onBack ?? () => exitRequestCreate(context),
              ),
            ),
            SizedBox(width: tokens.space.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null && eyebrow!.isNotEmpty)
                    Text(
                      fonts.isArabic ? eyebrow! : eyebrow!.toUpperCase(),
                      style: fonts
                          .sansStyle(10, FontWeight.w600, trackingEm: 0.10)
                          .copyWith(color: tokens.gold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    title,
                    style: fonts
                        .serifStyle(21, FontWeight.w600)
                        .copyWith(color: tokens.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CU-03 — create/review scaffold on [KhTokens.formSurface] with shared CTAs.
class CreateFlowChrome extends StatelessWidget {
  const CreateFlowChrome({
    super.key,
    required this.title,
    this.eyebrow,
    this.stepLabel = '',
    required this.child,
    this.bottom,
    this.onRefresh,
    this.onBack,
  });

  final String title;
  final String? eyebrow;
  final String stepLabel;
  final Widget child;
  final Widget? bottom;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    final effectiveEyebrow = (eyebrow != null && eyebrow!.isNotEmpty)
        ? eyebrow!
        : stepLabel;

    Widget content = KeyboardAvoidingView(child: child);

    if (onRefresh != null) {
      content = KhPullToRefresh(onRefresh: onRefresh!, child: content);
    }

    return Scaffold(
      backgroundColor: tokens.formSurface,
      appBar: CreateFlowHeader(
        title: title,
        eyebrow: effectiveEyebrow,
        onBack: onBack,
        height: createFlowHeaderHeight(MediaQuery.textScalerOf(context)),
      ),
      body: SafeArea(
        child: KhCenteredContent(
          child: Column(
            children: [
              Expanded(child: content),
              if (bottom != null) bottom!,
            ],
          ),
        ),
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

/// Bottom bar for compose steps: text Save draft + filled Continue (T02).
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
    return Container(
      decoration: BoxDecoration(
        color: tokens.formSurface,
        border: Border(top: BorderSide(color: tokens.inkHairline, width: 1.0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(1);
          // Measure the bar, not the padded interior (16 + 16).
          final stack = constraints.maxWidth < khNarrowWidth || scale >= 1.4;
          final save = TextButton(
            key: const Key('create-save-draft'),
            onPressed: busy ? null : onSaveDraft,
            child: busy
                ? SizedBox(
                    height: tokens.space.md,
                    width: tokens.space.md,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(createCopy(context, 'create.saveDraft', 'Save draft')),
          );
          final continueButton = KhButton(
            label:
                continueLabel ??
                createCopy(context, 'create.continue', 'Continue'),
            busy: busy,
            onPressed: continueEnabled && !busy ? onContinue : null,
            width: stack ? double.infinity : null,
          );
          final bar = stack
              ? Column(
                  key: const Key('create-draft-actions'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    save,
                    SizedBox(height: tokens.space.sm),
                    continueButton,
                  ],
                )
              : Row(
                  key: const Key('create-draft-actions'),
                  children: [
                    Flexible(child: save),
                    SizedBox(width: tokens.space.sm),
                    Expanded(child: continueButton),
                  ],
                );
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space.md,
              vertical: tokens.space.sm,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: bar,
            ),
          );
        },
      ),
    );
  }
}
