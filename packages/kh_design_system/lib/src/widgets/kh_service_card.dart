import 'package:flutter/material.dart';

import 'package:kh_design_system/src/theme.dart';
import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';

/// Layout for [KhServiceCard].
enum KhServiceCardStyle {
  /// Full-bleed photo with title + gold arrow overlaid (Guest Landing).
  fullBleed,

  /// Photo well + ivory caption band with ink title + soft arrow disc (Home-1).
  captionBand,
}

/// Request-type photography tile for the 2×2 grid on Customer Home and Guest
/// Landing (Home-1 / visual pass H02).
///
/// The whole card is one tap target and one semantics node.
class KhServiceCard extends StatefulWidget {
  const KhServiceCard({
    super.key,
    required this.title,
    required this.onTap,
    this.image,
    this.tapKey,
    this.style = KhServiceCardStyle.fullBleed,
  });

  final String title;

  final VoidCallback onTap;

  /// Cover photo. Stripe placeholder when null.
  final ImageProvider? image;

  /// Key for the inner tap target, for tests and deep links.
  final Key? tapKey;

  /// [KhServiceCardStyle.captionBand] for Customer Home; full-bleed elsewhere.
  final KhServiceCardStyle style;

  @override
  State<KhServiceCard> createState() => _KhServiceCardState();
}

class _KhServiceCardState extends State<KhServiceCard> {
  static const _fullBleedHeight = 168.0;
  static const _captionPhotoHeight = 148.0;

  /// Soft disc behind the caption-band arrow (Home-1 / Card-mock).
  static const _arrowDisc = Color(0xFFEFE4D9);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final type = Theme.of(context).textTheme;
    final fonts = KhFonts.forLocale(Localizations.localeOf(context));
    final radius = BorderRadius.circular(t.radius.card);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final Widget body;
    final double tileHeight;

    if (widget.style == KhServiceCardStyle.captionBand) {
      final titleStyle = fonts
          .serifStyle(20, FontWeight.w600, height: 1.15)
          .copyWith(color: t.ink);
      tileHeight = (_captionPhotoHeight + 64) *
          MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(t.radius.card)),
              child: _Photo(image: widget.image),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(t.space.s12, t.space.s12, t.space.s12, t.space.s14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
                SizedBox(width: t.space.sm),
                _ArrowChip(fill: _arrowDisc, iconColor: t.gold),
              ],
            ),
          ),
        ],
      );
    } else {
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
      tileHeight = _fullBleedHeight *
          MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
      body = Stack(
        fit: StackFit.expand,
        children: [
          _Photo(image: widget.image),
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
                _ArrowChip(fill: t.gold, iconColor: t.ink),
              ],
            ),
          ),
        ],
      );
    }

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
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.image});

  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Image(
        image: image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) =>
            CustomPaint(painter: KhStripePainter.onIvory()),
      );
    }
    return CustomPaint(painter: KhStripePainter.onIvory());
  }
}

class _ArrowChip extends StatelessWidget {
  const _ArrowChip({required this.fill, required this.iconColor});

  final Color fill;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      // Icons.arrow_forward mirrors in RTL automatically.
      child: Icon(Icons.arrow_forward, size: 17, color: iconColor),
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
