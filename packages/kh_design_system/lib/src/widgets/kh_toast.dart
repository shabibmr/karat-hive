import 'package:flutter/material.dart';

import '../tokens.dart';

/// Tone for SH-FND-17 toast / snackbar variants.
enum KhToastTone { success, error, info }

/// SH-FND-17 — transient toast / snackbar (success, error, info).
class KhToast extends StatelessWidget {
  const KhToast({
    super.key,
    required this.message,
    this.tone = KhToastTone.info,
  });

  final String message;
  final KhToastTone tone;

  Color _background(KhTokens tokens) {
    return switch (tone) {
      KhToastTone.success => tokens.success,
      KhToastTone.error => tokens.danger,
      KhToastTone.info => tokens.info,
    };
  }

  IconData get _icon {
    return switch (tone) {
      KhToastTone.success => Icons.check_circle_outline,
      KhToastTone.error => Icons.error_outline,
      KhToastTone.info => Icons.info_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final foreground = tokens.surface;
    return Semantics(
      liveRegion: true,
      label: message,
      child: Material(
        key: const Key('kh-toast'),
        color: _background(tokens),
        elevation: 2,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.sm,
          ),
          child: Row(
            children: [
              Icon(_icon, color: foreground, size: 20),
              SizedBox(width: tokens.space.sm),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows [KhToast] via [ScaffoldMessenger] as a floating snackbar.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showKhToast(
  BuildContext context, {
  required String message,
  KhToastTone tone = KhToastTone.info,
  Duration duration = const Duration(seconds: 4),
  Key? key,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  return messenger.showSnackBar(
    SnackBar(
      key: key,
      content: KhToast(message: message, tone: tone),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      duration: duration,
    ),
  );
}
