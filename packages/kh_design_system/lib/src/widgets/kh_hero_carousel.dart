import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kh_design_system/src/theme.dart';
import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';
import 'package:kh_design_system/src/widgets/kh_service_card.dart';
import 'package:kh_design_system/src/widgets/kh_home_style.dart';

/// One slide of a [KhHeroCarousel]: a gold lead line, two ivory lines, and a
/// photo pane.
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

  /// Until real photography exists, a dark stripe placeholder fills the pane.
  final ImageProvider? image;
}

/// Ink hero carousel on Customer Home (`UI-Design-Context.md` §6.11, §8).
///
/// Swipeable [PageView]; autoplays every 4.2 s, pausing while dragged, while
/// the route's tickers are muted (another tab is showing) and entirely under
/// reduced motion. A manual change restarts the timer. The height follows the
/// tallest slide (min 208), so wrapped Arabic or large text never clips.
class KhHeroCarousel extends StatefulWidget {
  const KhHeroCarousel({
    super.key,
    required this.slides,
    required this.dotLabel,
    this.autoplay = true,
    this.editorial = false,
    this.previousLabel,
    this.nextLabel,
  }) : assert(slides.length > 0);

  final List<KhHeroSlide> slides;

  /// Semantics label for dot [index] (0-based) of [count], e.g. "Slide 2 of 4".
  final String Function(int index, int count) dotLabel;

  final bool autoplay;
  final bool editorial;
  final String? previousLabel;
  final String? nextLabel;

  @override
  State<KhHeroCarousel> createState() => _KhHeroCarouselState();
}

class _KhHeroCarouselState extends State<KhHeroCarousel> {
  static const _minHeight = 208.0;

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
    if (oldWidget.autoplay != widget.autoplay ||
        oldWidget.slides.length != widget.slides.length) {
      _restartTimer();
    }
    if (_page >= widget.slides.length) {
      _page = widget.slides.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) _controller.jumpToPage(_page);
      });
    }
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

    if (widget.editorial) {
      return _EditorialHero(
        slides: widget.slides,
        controller: _controller,
        currentPage: _page,
        dotLabel: widget.dotLabel,
        previousLabel: widget.previousLabel,
        nextLabel: widget.nextLabel,
        onScroll: _onScroll,
        onPageChanged: (i) => setState(() => _page = i),
        onSelect: _goTo,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(t.radius.card),
      child: ColoredBox(
        color: t.ink,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Stack(
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
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      for (final slide in widget.slides) _Slide(slide: slide),
                    ],
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
                          label: widget.dotLabel(i, count),
                          onTap: () => _goTo(i),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorialHero extends StatelessWidget {
  const _EditorialHero({
    required this.slides,
    required this.controller,
    required this.currentPage,
    required this.dotLabel,
    required this.previousLabel,
    required this.nextLabel,
    required this.onScroll,
    required this.onPageChanged,
    required this.onSelect,
  });

  final List<KhHeroSlide> slides;
  final PageController controller;
  final int currentPage;
  final String Function(int, int) dotLabel;
  final String? previousLabel;
  final String? nextLabel;
  final bool Function(ScrollNotification) onScroll;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final inset = width * 0.11;
      final captionWidth = width * 0.48;
      final font = KhFonts.forLocale(Localizations.maybeLocaleOf(context));
      final style = font
          .serifStyle(
            (width * 0.084).clamp(24, 38),
            FontWeight.w500,
            height: 1.07,
          )
          .copyWith(color: KhHomeStyle.headline);
      var height = width / 1.5;
      for (final slide in slides) {
        final measure = TextPainter(
          text: TextSpan(text: _caption(slide), style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: captionWidth);
        final needed = measure.height + 76;
        if (needed > height) height = needed;
        measure.dispose();
      }
      return SizedBox(
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(KhHomeStyle.radius),
                child: NotificationListener<ScrollNotification>(
                  onNotification: onScroll,
                  child: PageView(
                    controller: controller,
                    onPageChanged: onPageChanged,
                    children: [
                      for (final slide in slides)
                        Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(
                              color: KhHomeStyle.cream,
                              child: slide.image == null
                                  ? const SizedBox.shrink()
                                  : Image(
                                      image: slide.image!,
                                      fit: BoxFit.cover,
                                      matchTextDirection: true,
                                      excludeFromSemantics: true,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink(),
                                    ),
                            ),
                            PositionedDirectional(
                              start: inset,
                              top: 0,
                              bottom: 30,
                              width: captionWidth,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(_caption(slide), style: style),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (slides.length > 1) ...[
              PositionedDirectional(
                start: inset,
                bottom: 7,
                child: Row(
                  children: [
                    for (var i = 0; i < slides.length; i++)
                      Semantics(
                        button: true,
                        selected: currentPage == i,
                        label: dotLabel(i, slides.length),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onSelect(i),
                          child: SizedBox(
                            width: 16,
                            height: 44,
                            child: Center(
                              child: Container(
                                width: currentPage == i ? 12 : 7,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: currentPage == i
                                      ? const Color(0xFF9C6B30)
                                      : const Color(0xFFDED6CD),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              PositionedDirectional(
                start: -18,
                top: (height - 44) / 2,
                child: _HeroArrow(
                  label: previousLabel,
                  forward: false,
                  onTap: () => onSelect(
                    (currentPage - 1 + slides.length) % slides.length,
                  ),
                ),
              ),
              PositionedDirectional(
                end: -18,
                top: (height - 44) / 2,
                child: _HeroArrow(
                  label: nextLabel,
                  forward: true,
                  onTap: () => onSelect((currentPage + 1) % slides.length),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );

  static String _caption(KhHeroSlide slide) => [
    slide.lead,
    slide.line2,
    slide.line3,
  ].where((s) => s.isNotEmpty).join('\n');
}

class _HeroArrow extends StatelessWidget {
  const _HeroArrow({
    required this.label,
    required this.forward,
    required this.onTap,
  });
  final String? label;
  final bool forward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 44,
    child: IconButton(
      tooltip: label,
      onPressed: onTap,
      style: IconButton.styleFrom(
        foregroundColor: KhHomeStyle.gold,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.all(4),
      ),
      icon: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: KhHomeStyle.background,
          shape: BoxShape.circle,
        ),
        child: Icon(
          forward ? Icons.chevron_right : Icons.chevron_left,
          size: 26,
        ),
      ),
    ),
  );
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide, this.sizingOnly = false});

  final KhHeroSlide slide;

  /// Lays out the text pane only, under unbounded height, to measure the
  /// slide; the photo pane has no intrinsic height of its own.
  final bool sizingOnly;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final type = context.typography;

    return Row(
      crossAxisAlignment: sizingOnly
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 115,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 22, 6, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slide.lead, style: type.heroLead),
                SizedBox(height: t.space.xxs),
                Text(slide.line2, style: type.heroBody),
                SizedBox(height: t.space.xxs),
                Text(slide.line3, style: type.heroBody),
                SizedBox(height: t.space.s12),
                Container(width: 28, height: 1.5, color: t.gold),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 100,
          child: sizingOnly
              ? const SizedBox.shrink()
              : slide.image != null
              ? Image(image: slide.image!, fit: BoxFit.cover)
              : CustomPaint(painter: KhStripePainter.onInk()),
        ),
      ],
    );
  }
}

/// Active 18 × 6 gold pill, idle 6 × 6 ivory @ 0.45; the padding gives each
/// dot a tall hit area without spreading the dots apart.
class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.label, required this.onTap});

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
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
              color: active ? t.gold : t.ivoryDotIdle,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
