import 'package:flutter/material.dart';

import 'package:kh_design_system/src/theme.dart';
import 'package:kh_design_system/src/tokens.dart';

/// Request-type photography tile for the 2×2 grid on Customer Home and Guest
/// Landing (Home-1 / visual pass H02).
///
/// Full-bleed photo, serif title and gold arrow overlaid at the bottom. The
/// whole card is one tap target and one semantics node.
class KhServiceCard extends StatefulWidget {
  const KhServiceCard({
    super.key,
    required this.title,
    required this.onTap,
    this.image,
    this.tapKey,
  });

  final String title;

  final VoidCallback onTap;

  /// Cover photo. Stripe placeholder when null.
  final ImageProvider? image;

  /// Key for the inner tap target, for tests and deep links.
  final Key? tapKey;

  @override
  State<KhServiceCard> createState() => _KhServiceCardState();
}

class _KhServiceCardState extends State<KhServiceCard> {
  static const _tileHeight = 168.0;

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final type = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(t.radius.card);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final titleStyle = type.titleMedium?.copyWith(
      color: t.surface,
      shadows: [
        Shadow(
          color: t.ink.withValues(alpha: 0.45),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ],
    );

    final tile = Stack(
      fit: StackFit.expand,
      children: [
        if (widget.image != null)
          Image(
            image: widget.image!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                CustomPaint(painter: KhStripePainter.onIvory()),
          )
        else
          CustomPaint(painter: KhStripePainter.onIvory()),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                t.ink.withValues(alpha: 0),
                t.ink.withValues(alpha: 0.40),
                t.ink.withValues(alpha: 0.60),
              ],
              stops: const [0.30, 0.72, 1],
            ),
          ),
        ),
        PositionedDirectional(
          start: t.space.s12,
          end: t.space.s12,
          bottom: t.space.s12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              SizedBox(width: t.space.sm),
              const _ArrowChip(),
            ],
          ),
        ),
      ],
    );

    // Fixed base height so KhServiceGrid's IntrinsicHeight resolves; it grows
    // with the text scale so a wrapped title stays on the scrim.
    final tileHeight =
        _tileHeight * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    return Semantics(
      button: true,
      label: widget.title,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : KhMotion.cardPress,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: radius,
          border: Border.all(color: t.inkBorderSoft),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: t.ink.withValues(alpha: 0.08),
                    offset: const Offset(0, 6),
                    blurRadius: 18,
                  ),
                ]
              : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: widget.tapKey,
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            onHover: (v) => setState(() => _pressed = v),
            borderRadius: radius,
            child: ClipRRect(
              borderRadius: radius,
              child: SizedBox(
                height: tileHeight,
                width: double.infinity,
                child: tile,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowChip extends StatelessWidget {
  const _ArrowChip();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: t.gold, shape: BoxShape.circle),
      // Icons.arrow_forward mirrors in RTL automatically.
      child: Icon(Icons.arrow_forward, size: 17, color: t.ink),
    );
  }
}

/// 135° diagonal stripe (6 px bands) standing in for unsourced photography
/// (§2.2).
class KhStripePainter extends CustomPainter {
  const KhStripePainter({required this.a, required this.b});

  /// Stripes for image slots on ivory (service tiles, thumbnails).
  factory KhStripePainter.onIvory() =>
      const KhStripePainter(a: Color(0xFFF1E9D8), b: Color(0xFFF8F3E8));

  /// Stripes for image slots on ink (hero photo pane).
  factory KhStripePainter.onInk() =>
      const KhStripePainter(a: Color(0xFF2A2723), b: Color(0xFF33302A));

  final Color a;
  final Color b;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = b);
    final paint = Paint()
      ..color = a
      ..strokeWidth = 6;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // CSS 135° bands: 6 px wide, repeating every 12 px across the stripe,
    // so 12·√2 apart horizontally, running bottom-start to top-end.
    const step = 12 * 1.4142;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(KhStripePainter old) => old.a != a || old.b != b;
}
