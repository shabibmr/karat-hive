import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

String createCopy(BuildContext context, String key, String fallback) {
  final value = KhStrings.of(context).s(key);
  return value == key ? fallback : value;
}

/// 60px top header block for CreateFlowChrome.
class CreateFlowHeader extends StatelessWidget implements PreferredSizeWidget {
  const CreateFlowHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.onBack,
  });

  final String title;
  final String? eyebrow;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final locale = Localizations.maybeLocaleOf(context);
    final fonts = KhFonts.forLocale(locale);

    return Container(
      height: 60,
      color: tokens.surface,
      padding: EdgeInsets.symmetric(horizontal: tokens.space.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: tokens.inkBorderSoft,
                width: 1,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: const Icon(Icons.arrow_back),
              color: tokens.ink,
              onPressed: onBack ?? () => Navigator.maybePop(context),
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
                    style: fonts.sansStyle(
                      10,
                      FontWeight.w600,
                      trackingEm: 0.10,
                    ).copyWith(color: tokens.gold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  title,
                  style: fonts.serifStyle(
                    21,
                    FontWeight.w600,
                  ).copyWith(color: tokens.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CU-03 — step progress + header block + keyboard-avoiding column.
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

    Widget content = KeyboardAvoidingView(
      child: child,
    );

    if (onRefresh != null) {
      content = KhPullToRefresh(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CreateFlowHeader(
        title: title,
        eyebrow: effectiveEyebrow,
        onBack: onBack,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: content,
            ),
            if (bottom != null)
              SafeArea(
                top: false,
                child: bottom!,
              ),
          ],
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
        border: Border(
          top: BorderSide(color: tokens.inkHairline, width: 1.0),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.sm,
      ),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: KhButton(
                key: const Key('create-save-draft'),
                secondary: true,
                label: createCopy(context, 'create.saveDraft', 'Save draft'),
                busy: busy,
                onPressed: busy ? null : onSaveDraft,
                width: null,
              ),
            ),
            SizedBox(width: tokens.space.sm),
            Expanded(
              flex: 18,
              child: KhButton(
                label: continueLabel ?? createCopy(context, 'create.continue', 'Continue'),
                busy: busy,
                onPressed: continueEnabled && !busy ? onContinue : null,
                width: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
