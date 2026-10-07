import 'package:flutter/material.dart';

import 'package:kh_design_system/src/theme.dart';
import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';
import 'package:kh_design_system/src/widgets/kh_home_style.dart';

/// Request-type service tile used in the 2×2 grid on Customer Home and Guest
/// Landing (`UI-Design-Context.md` §6.10).
///
/// Photo band (86 px) with a start-inset icon badge, a two-line serif title,
/// and a gold arrow chip at the end. The whole card is one tap target and one
/// semantics node.
class KhServiceCard extends StatefulWidget {
  const KhServiceCard({
    super.key,
    required this.title,
    this.icon,
    required this.onTap,
    this.image,
    this.tapKey,
    this.expand = false,
    this.editorial = false,
  });

  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  /// Cover photo. Until real photography exists, a striped placeholder (§2.2)
  /// fills the band.
  final ImageProvider? image;

  /// Key for the inner tap target, for tests and deep links.
  final Key? tapKey;

  /// Fill a height-constrained slot (a stretched grid row) and pin the arrow
  /// chip to the bottom edge, so wrapped titles don't stagger the arrows.
  final bool expand;
  final bool editorial;

  @override
  State<KhServiceCard> createState() => _KhServiceCardState();
}

class _KhServiceCardState extends State<KhServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.editorial) {
      return _EditorialServiceCard(
        title: widget.title,
        image: widget.image,
        onTap: widget.onTap,
        tapKey: widget.tapKey,
      );
    }
    final t = context.tokens;
    final type = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(t.radius.card);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final bounded = widget.expand;
    final body = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        t.space.s12,
        t.space.s10,
        t.space.s12,
        t.space.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: type.titleMedium,
          ),
          SizedBox(height: t.space.sm),
          if (bounded) const Spacer(),
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _ArrowChip(),
          ),
        ],
      ),
    );

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
              child: Column(
                mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 86,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (widget.image != null)
                          Image(image: widget.image!, fit: BoxFit.cover)
                        else
                          CustomPaint(painter: KhStripePainter.onIvory()),
                        if (widget.icon != null)
                          PositionedDirectional(
                            top: t.space.s10,
                            start: t.space.s10,
                            child: _IconBadge(icon: widget.icon!),
                          ),
                      ],
                    ),
                  ),
                  // In a stretched grid row the body fills the remaining
                  // height so every arrow chip sits on the bottom edge.
                  if (bounded) Expanded(child: body) else body,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorialServiceCard extends StatelessWidget {
  const _EditorialServiceCard({
    required this.title,
    required this.image,
    required this.onTap,
    required this.tapKey,
  });

  final String title;
  final ImageProvider? image;
  final VoidCallback onTap;
  final Key? tapKey;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final font = KhFonts.forLocale(Localizations.maybeLocaleOf(context));
      final style = font
          .serifStyle(
            (width * 0.1).clamp(18, 25),
            FontWeight.w500,
            height: 1.08,
          )
          .copyWith(color: KhHomeStyle.ink);
      final measure = TextPainter(
        text: TextSpan(text: title, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: width - 66);
      final footerHeight = (measure.height + 20).clamp(58.0, double.infinity);
      measure.dispose();
      final imageHeight = width * 0.86;
      return Semantics(
        button: true,
        label: title.replaceAll('\n', ' '),
        onTap: onTap,
        excludeSemantics: true,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KhHomeStyle.radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x09000000),
                blurRadius: 18,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: KhHomeStyle.cream,
            borderRadius: BorderRadius.circular(KhHomeStyle.radius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: tapKey,
              onTap: onTap,
              child: SizedBox(
                height: imageHeight + footerHeight - 18,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: imageHeight,
                      child: image == null
                          ? const SizedBox.shrink()
                          : Image(
                              image: image!,
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: footerHeight,
                      child: ClipPath(
                        clipper: const _LabelPanelClipper(),
                        child: ColoredBox(
                          color: KhHomeStyle.background,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              14,
                              12,
                              12,
                              8,
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(title, style: style)),
                                const SizedBox(width: 8),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: KhHomeStyle.cream,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    size: 21,
                                    color: KhHomeStyle.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _LabelPanelClipper extends CustomClipper<Path> {
  const _LabelPanelClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 16)
    ..cubicTo(size.width * 0.10, -8, size.width * 0.32, 0, size.width * 0.54, 8)
    ..cubicTo(size.width * 0.74, 16, size.width * 0.91, -1, size.width, 14)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_LabelPanelClipper oldClipper) => false;
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius.chipMd),
        boxShadow: [
          BoxShadow(
            color: t.ink.withValues(alpha: 0.10),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Icon(icon, size: 19, color: t.gold),
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
      child: Icon(Icons.arrow_forward, size: 17, color: t.surface),
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
