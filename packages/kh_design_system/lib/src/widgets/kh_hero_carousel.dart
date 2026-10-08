import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kh_design_system/src/theme.dart';
import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';
import 'package:kh_design_system/src/widgets/kh_service_card.dart';

/// One slide of a [KhHeroCarousel]: display lines over jewellery photography.
class KhHeroSlide {
  const KhHeroSlide({
    required this.lead,
    required this.line2,
    required this.line3,
    this.image,
  });

  final String lead;
  final String line2;
  final String line3;

  /// Full-bleed photo behind the display lines. Stripe placeholder when null.
  final ImageProvider? image;
}

/// Hero carousel on Customer Home — jewellery photography with dark serif
/// display lines on the image (Home-1).
///
/// Swipeable [PageView]; autoplays every 4.2 s, pausing while dragged, while
/// the route's tickers are muted (another tab is showing) and entirely under
/// reduced motion. A manual change restarts the timer. White chevron discs
/// overhang the left and right edges; only the photograph is clipped.
class KhHeroCarousel extends StatefulWidget {
  const KhHeroCarousel({
    super.key,
    required this.slides,
    required this.dotLabel,
    required this.nextLabel,
    this.prevLabel,
    this.autoplay = true,
  });

  final List<KhHeroSlide> slides;

  /// Semantics label for dot [index] (0-based) of [count], e.g. "Slide 2 of 4".
  final String Function(int index, int count) dotLabel;

  /// Semantics label for the next-slide button.
  final String nextLabel;

  /// Semantics label for the previous-slide button. Falls back to [nextLabel].
  final String? prevLabel;

  final bool autoplay;

  @override
  State<KhHeroCarousel> createState() => _KhHeroCarouselState();
}

class _KhHeroCarouselState extends State<KhHeroCarousel> {
  static const _minHeight = 208.0;
  static const _maxMinHeight = 320.0;
  static const _chevronOverhang = 20.0;

  /// Home-1 active capsule / idle dots.
  static const _dotActive = Color(0xFF9D7036);
  static const _dotIdle = Color(0xFFE1D8CF);

  final _controller = PageController();
  Timer? _timer;
  int _page = 0;
  bool _dragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartTimer();
  }

  @override
  void didUpdateWidget(KhHeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoplay != widget.autoplay) _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    if (!widget.autoplay || _reduceMotion || widget.slides.length < 2) return;
    _timer = Timer.periodic(KhMotion.carouselInterval, (_) => _advance());
  }

  void _advance() {
    // TickerMode is off while this tab sits behind another in the shell.
    if (!mounted || _dragging || !TickerMode.valuesOf(context).enabled) return;
    if (!_controller.hasClients) return;
    _goTo((_page + 1) % widget.slides.length, restart: false);
  }

  void _goTo(int index, {bool restart = true}) {
    if (_reduceMotion) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(
        index,
        duration: KhMotion.carouselSlide,
        curve: KhMotion.carouselCurve,
      );
    }
    if (restart) _restartTimer();
  }

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _dragging = true;
    } else if (n is ScrollEndNotification && _dragging) {
      _dragging = false;
      _restartTimer();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final count = widget.slides.length;
    final prevLabel = widget.prevLabel ?? 'Previous slide';

    return Padding(
      // Room for the half-outside chevron discs.
      padding: const EdgeInsets.symmetric(horizontal: _chevronOverhang),
      child: LayoutBuilder(
        builder: (context, box) => ConstrainedBox(
          // 208 on phones; on wide columns grow toward 21:9 (capped at 320)
          // so the landscape photo isn't cropped to a thin strip.
          constraints: BoxConstraints(
            minHeight: (box.maxWidth * 9 / 21)
                .clamp(_minHeight, _maxMinHeight)
                .toDouble(),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Invisible copies of every slide size the Stack to the tallest
              // one; the PageView then fills that height.
              for (final slide in widget.slides)
                ExcludeSemantics(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0,
                      child: _Slide(slide: slide, sizingOnly: true),
                    ),
                  ),
                ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(t.radius.card),
                  child: ColoredBox(
                    color: t.ink,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScroll,
                      child: PageView(
                        controller: _controller,
                        onPageChanged: (i) => setState(() => _page = i),
                        children: [
                          for (final slide in widget.slides)
                            _Slide(slide: slide),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (count > 1)
                PositionedDirectional(
                  start: 15,
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < count; i++)
                        _Dot(
                          active: i == _page,
                          activeColor: _dotActive,
                          idleColor: _dotIdle,
                          label: widget.dotLabel(i, count),
                          onTap: () => _goTo(i),
                        ),
                    ],
                  ),
                ),
              if (count > 1) ...[
                PositionedDirectional(
                  start: -_chevronOverhang,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _HeroChevronButton(
                      label: prevLabel,
                      icon: Icons.chevron_left,
                      onPressed: () => _goTo(
                        (_page - 1 + widget.slides.length) %
                            widget.slides.length,
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: -_chevronOverhang,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _HeroChevronButton(
                      label: widget.nextLabel,
                      icon: Icons.chevron_right,
                      onPressed: () =>
                          _goTo((_page + 1) % widget.slides.length),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide, this.sizingOnly = false});

  final KhHeroSlide slide;

  /// Lays out the text column only, under unbounded height, to measure the
  /// slide; the photo has no intrinsic height of its own.
  final bool sizingOnly;

  /// Home-1 editorial ink on the photograph.
  static const _editorialInk = Color(0xFF303331);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fonts = KhFonts.forLocale(Localizations.localeOf(context));
    final lineStyle =
        fonts.serifStyle(32, FontWeight.w500, height: 1.15).copyWith(
              color: _editorialInk,
            );

    final text = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(28, 28, 56, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(slide.lead, style: lineStyle),
          SizedBox(height: t.space.xxs),
          Text(slide.line2, style: lineStyle),
          SizedBox(height: t.space.xxs),
          Text(slide.line3, style: lineStyle),
        ],
      ),
    );

    if (sizingOnly) return text;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: slide.image != null
              ? Image(
                  image: slide.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      CustomPaint(painter: KhStripePainter.onInk()),
                )
              : CustomPaint(painter: KhStripePainter.onInk()),
        ),
        text,
      ],
    );
  }
}

/// White circle with a gold chevron; hangs half outside the photo (Home-1).
class _HeroChevronButton extends StatelessWidget {
  const _HeroChevronButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // 48 px hit area around the 40 px visual circle.
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: t.paper,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: t.ink.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 22, color: t.gold),
            ),
          ),
        ),
      ),
    );
  }
}

/// Active 18 × 6 gold pill, idle 6 × 6 warm grey; the padding gives each
/// dot a tall hit area without spreading the dots apart.
class _Dot extends StatelessWidget {
  const _Dot({
    required this.active,
    required this.activeColor,
    required this.idleColor,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final Color activeColor;
  final Color idleColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : KhMotion.select;

    return Semantics(
      button: true,
      selected: active,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3, 20, 3, 14),
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOut,
            width: active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? activeColor : idleColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
