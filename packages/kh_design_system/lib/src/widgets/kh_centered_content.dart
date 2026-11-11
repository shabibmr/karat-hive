import 'package:flutter/widgets.dart';

/// Centres a child in a column no wider than [maxWidth].
///
/// The child still receives a bounded max height, so a [ListView] or a
/// [Column] with [Expanded] can be the child.
class KhCenteredContent extends StatelessWidget {
  const KhCenteredContent({super.key, required this.child});

  static const double maxWidth = 560;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
