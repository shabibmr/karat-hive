import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Insets the app into the phone's safe area.
///
/// iPhone and Android draw the Flutter view edge to edge, under the status
/// bar, Dynamic Island, and home indicator. Screens that only pad some edges
/// then sit their buttons and text in that system chrome. This frame applies
/// the inset once and clears it from [MediaQuery] so [SafeArea] and [AppBar]
/// do not add it again.
///
/// While the keyboard is open the bottom system inset is left to
/// [MediaQueryData.viewInsets], so the home indicator is not stacked on the
/// keyboard.
class KhSystemInset extends StatelessWidget {
  const KhSystemInset({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardOpen = mq.viewInsets.bottom > 0;
    final bottom = keyboardOpen
        ? mq.padding.bottom
        : math.max(mq.padding.bottom, mq.viewPadding.bottom);
    final pad = EdgeInsets.fromLTRB(
      math.max(mq.padding.left, mq.viewPadding.left),
      math.max(mq.padding.top, mq.viewPadding.top),
      math.max(mq.padding.right, mq.viewPadding.right),
      bottom,
    );
    if (pad == EdgeInsets.zero) return child;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: pad,
        child: MediaQuery(
          data: mq.copyWith(
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
          ),
          child: child,
        ),
      ),
    );
  }
}
