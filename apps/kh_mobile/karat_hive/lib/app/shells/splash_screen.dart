import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// Karat Hive luxury mobile splash screen with cinematic logo reveal animation.
///
/// Follows Stitch UI and Motion Design specifications:
/// - Dark Luxury / Deep Ink (#1C1B1A) background with subtle radial gold gradient glow
/// - Micro-ambient hexagonal particle dust drifting at 0.05 opacity
/// - Central Hero Stage (at ~40% vertical height):
///   * Brand logo (assets/karat-hive-logo.png) on an ivory plate, with a gold glow sweep
///   * Sub-tagline "The Modern Gold Standard" in DM Sans 12px uppercase
/// - Minimalist 32px gold hairline loader 60px from bottom edge.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _revealController;
  late final AnimationController _ambientController;

  // Keyframe timeline animations (0.0s to 2.2s total reveal sequence)
  late final Animation<double> _emblemScale;
  late final Animation<double> _emblemOpacity;
  late final Animation<double> _specularProgress;
  late final Animation<double> _wordmarkSlide;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // 0.00s – 0.65s (0.0 to ~0.30): Logo scale + opacity
    _emblemScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.30, curve: Cubic(0.2, 0.7, 0.2, 1.0)),
      ),
    );
    _emblemOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
    );

    // 0.65s – 1.10s (0.30 to 0.50): Specular 45-degree gold glint sweep
    _specularProgress = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.30, 0.52, curve: Curves.easeOutQuad),
    );

    // 0.80s – 1.40s (0.36 to 0.64): "Karat Hive" Wordmark staggered slide & fade
    _wordmarkSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.36, 0.64, curve: Cubic(0.16, 1.0, 0.3, 1.0)),
      ),
    );

    // 1.40s – 2.00s (0.64 to 0.90): Sub-tagline fades in
    _taglineOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.64, 0.90, curve: Curves.easeOut),
    );

    _revealController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const deepInk = Color(0xFF1C1B1A);
    const karatGold = Color(0xFFC8A046);
    const ivoryWhite = Color(0xFFFDFBF7);

    final fonts = KhFonts.forLocale(Localizations.maybeLocaleOf(context));
    final strings = KhStrings.of(context);
    final brandTitle = strings.s('guest.title');
    final tagline = strings.s('splash.tagline');

    return Scaffold(
      backgroundColor: deepInk,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Canvas: Radial gold gradient glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.2), // Anchored to Hero stage
                  radius: 0.85,
                  colors: [
                    karatGold.withValues(alpha: 0.12),
                    deepInk.withValues(alpha: 0.6),
                    deepInk,
                  ],
                  stops: const [0.0, 0.45, 0.85],
                ),
              ),
            ),
          ),

          // 2. Micro-ambient hexagonal particle dust drifting slowly
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, _) => CustomPaint(
              painter: _HexagonalParticleDustPainter(
                progress: _ambientController.value,
                particleColor: karatGold.withValues(alpha: 0.05),
              ),
            ),
          ),

          // 3. Central Hero Stage (Logo + Tagline) centered at ~40% height
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3), // ~35-40% height anchor
                AnimatedBuilder(
                  animation: Listenable.merge([_revealController, _ambientController]),
                  builder: (context, _) {
                    // Ambient breathing pulse (1.00 ↔ 1.018) after initial reveal
                    final isRevealed = _revealController.isCompleted;
                    final ambientScale = isRevealed
                        ? 1.0 + (0.018 * math.sin(_ambientController.value * math.pi))
                        : 1.0;

                    return Transform.scale(
                      scale: _emblemScale.value * ambientScale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand logo (already carries the KARAT HIVE wordmark),
                          // on an ivory plate so its dark ink stays legible
                          Opacity(
                            opacity: _emblemOpacity.value,
                            child: Transform.translate(
                              offset: Offset(0, _wordmarkSlide.value),
                              child: Container(
                                key: const Key('splash-logo'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: ivoryWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: karatGold.withValues(alpha: 0.25 * _specularProgress.value),
                                      blurRadius: 24,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/karat-hive-logo.png',
                                  width: 220,
                                  fit: BoxFit.contain,
                                  semanticLabel: brandTitle,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Text(brandTitle, style: fonts.serifStyle(28, FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Sub-tagline ("THE MODERN GOLD STANDARD")
                          Opacity(
                            opacity: _taglineOpacity.value * 0.70,
                            child: Text(
                              fonts.isArabic ? tagline : tagline.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: fonts
                                  .sansStyle(11.5, FontWeight.w500, height: 1.2)
                                  .copyWith(
                                    color: ivoryWhite,
                                    letterSpacing: fonts.isArabic ? 0 : 2.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Spacer(flex: 4),

                // 4. Footer Status / Minimalist Hairline Loader (60px from bottom edge)
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: AnimatedBuilder(
                    animation: _ambientController,
                    builder: (context, _) {
                      final shimmer = _ambientController.value;
                      return Container(
                        width: 32,
                        height: 2.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              karatGold.withValues(alpha: 0.25),
                              Color.lerp(
                                karatGold,
                                ivoryWhite,
                                (shimmer - 0.5).abs() * 0.6,
                              )!,
                              karatGold.withValues(alpha: 0.25),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: karatGold.withValues(alpha: 0.20 * shimmer),
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating micro-ambient hexagonal particle dust
class _HexagonalParticleDustPainter extends CustomPainter {
  _HexagonalParticleDustPainter({
    required this.progress,
    required this.particleColor,
  });

  final double progress;
  final Color particleColor;

  // Fixed deterministic pseudo-random seeds for 20 ambient dust particles
  static final List<_DustParticle> _particles = List.generate(20, (i) {
    final randX = ((i * 73 + 19) % 100) / 100.0;
    final randY = ((i * 47 + 53) % 100) / 100.0;
    final size = 2.0 + (i % 3) * 1.2;
    final speed = 0.4 + (i % 4) * 0.2;
    return _DustParticle(x: randX, y: randY, size: size, speed: speed);
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = particleColor
      ..style = PaintingStyle.fill;

    for (final p in _particles) {
      // Slow upward drift with subtle horizontal sine oscillation
      final currentY = ((p.y - progress * p.speed * 0.15) % 1.0) * size.height;
      final currentX =
          (p.x * size.width) + (math.sin((progress * 2 * math.pi) + p.y * 10) * 8.0);

      _drawHexagon(canvas, Offset(currentX, currentY), p.size, paint);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60.0) * (math.pi / 180.0);
      final pt = center + Offset(radius * math.cos(angle), radius * math.sin(angle));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexagonalParticleDustPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DustParticle {
  const _DustParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });

  final double x;
  final double y;
  final double size;
  final double speed;
}
