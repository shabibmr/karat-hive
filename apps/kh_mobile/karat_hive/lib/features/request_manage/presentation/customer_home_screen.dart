import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';
import '../../request_create/controller/request_create_controller.dart';
import '../../request_create/pending_publish_intent.dart';
import '../../request_create/routes.dart';

/// CUS-S02 Customer Home / Dashboard — layout locked to `Home-1.png`.
///
/// Header (centred clover + KARAT HIVE · gold bell + avatar) → hero carousel →
/// caption-band service grid. The open-request list lives under My Requests.

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  /// Content column cap on tablet / landscape / web.
  static const _maxContentWidth = 560.0;

  void _openService(BuildContext context, WidgetRef ref, RequestType type) {
    ref.read(requestCreateControllerProvider.notifier).selectType(type);
    context.push(RequestCreatePaths.composeFor(type));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final s = KhStrings.of(context);
    final session = ref.watch(sessionProvider);
    final customer =
        session is SignedIn ? session.user.customer : null;
    final displayName = customer?.displayName.trim() ?? '';
    final initial = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'K';
    final photoUrl = customer?.photoUrl;

    // Jewellery photography behind the display lines (Home-1).
    const heroPhoto = AssetImage('assets/images/hero_jewellery.webp');
    final slides = [
      for (var i = 1; i <= 3; i++)
        KhHeroSlide(
          lead: s.s('cus.home.hero.$i.a'),
          line2: s.s('cus.home.hero.$i.b'),
          line3: s.s('cus.home.hero.$i.c'),
          image: heroPhoto,
        ),
    ];

    final services = [
      (
        type: RequestType.findOrnament,
        key: const Key('customer-type-ornament'),
        title: s.s('service.card.home.ornament'),
        image: const AssetImage('assets/images/tile_find_ornament.webp'),
      ),
      (
        type: RequestType.sellOldGold,
        key: const Key('customer-type-sell-gold'),
        title: s.s('service.card.home.sellGold'),
        image: const AssetImage('assets/images/tile_sell_old_gold.webp'),
      ),
      (
        type: RequestType.goldCoin,
        key: const Key('customer-type-coins'),
        title: s.s('service.card.home.coins'),
        image: const AssetImage('assets/images/tile_gold_coin.webp'),
      ),
      (
        type: RequestType.goldBullion,
        key: const Key('customer-type-bullion'),
        title: s.s('service.card.home.bullion'),
        image: const AssetImage('assets/images/tile_gold_bullion.webp'),
      ),
    ];

    return Scaffold(
      key: const Key('customer-home-screen'),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HomeHeader(
                  alertsLabel: s.s('shell.nav.alerts'),
                  onAlerts: () => context.go(AppGuards.customerAlerts),
                  initial: initial,
                  photoUrl: photoUrl,
                  onAvatar: () => context.go(AppGuards.customerProfile),
                ),
                Expanded(
                  child: ListView(
                    clipBehavior: Clip.none,
                    padding: EdgeInsetsDirectional.fromSTEB(
                      tokens.space.md,
                      tokens.space.xs,
                      tokens.space.md,
                      tokens.space.lg,
                    ),
                    children: [
                      if (ref.watch(pendingPublishIntentProvider)) ...[
                        _RetryPublicationBanner(
                          key: const Key('retry-publication-banner'),
                          onRetry: () => ref
                              .read(requestCreateControllerProvider.notifier)
                              .reconcilePendingPublish(),
                        ),
                        SizedBox(height: tokens.space.md),
                      ],
                      KhHeroCarousel(
                        key: const Key('customer-home-hero'),
                        slides: slides,
                        dotLabel: (i, n) => s
                            .s('cus.home.heroDot')
                            .replaceAll('{n}', '${i + 1}')
                            .replaceAll('{count}', '$n'),
                        nextLabel: s.s('cus.home.heroNext'),
                        prevLabel: s.s('cus.home.heroPrev'),
                      ),
                      SizedBox(height: tokens.space.md),
                      KhServiceGrid(
                        children: [
                          for (final service in services)
                            KhServiceCard(
                              key: service.key,
                              title: service.title,
                              image: service.image,
                              style: KhServiceCardStyle.captionBand,
                              onTap: () =>
                                  _openService(context, ref, service.type),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home-1 header: centred clover + KARAT HIVE; trailing gold bell + avatar.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.alertsLabel,
    required this.onAlerts,
    required this.initial,
    required this.onAvatar,
    this.photoUrl,
  });

  final String alertsLabel;
  final VoidCallback onAlerts;
  final String initial;
  final String? photoUrl;
  final VoidCallback onAvatar;

  static const _clover = Color(0xFFA66D33);
  static const _wordmark = Color(0xFF1C1B1A);
  static const _avatarFill = Color(0xFFEFE2D7);
  static const _avatarLetter = Color(0xFF98784B);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fonts = KhFonts.forLocale(Localizations.localeOf(context));

    return SizedBox(
      height: 88,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space.md),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _CloverMark(color: _clover, size: 28),
                SizedBox(height: tokens.space.s6),
                Text(
                  fonts.isArabic ? 'كارات هايف' : 'KARAT HIVE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: fonts
                      .serifStyle(13, FontWeight.w600, height: 1.0)
                      .copyWith(
                        color: _wordmark,
                        letterSpacing: fonts.isArabic ? 0 : 3.2,
                      ),
                ),
              ],
            ),
            PositionedDirectional(
              end: 0,
              bottom: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KhBellButton(
                    key: const Key('customer-home-alerts'),
                    semanticLabel: alertsLabel,
                    showDot: true,
                    onPressed: onAlerts,
                  ),
                  SizedBox(width: tokens.space.sm),
                  _InitialAvatar(
                    initial: initial,
                    photoUrl: photoUrl,
                    fill: _avatarFill,
                    letterColor: _avatarLetter,
                    onTap: onAvatar,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four-petal clover mark sampled from Home-1 (`#A66D33`).
class _CloverMark extends StatelessWidget {
  const _CloverMark({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Karat Hive',
      child: CustomPaint(
        size: Size.square(size),
        painter: _CloverPainter(color),
      ),
    );
  }
}

class _CloverPainter extends CustomPainter {
  const _CloverPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final petalR = size.width * 0.28;
    final offset = size.width * 0.22;
    for (final o in [
      Offset(cx, cy - offset),
      Offset(cx + offset, cy),
      Offset(cx, cy + offset),
      Offset(cx - offset, cy),
    ]) {
      canvas.drawCircle(o, petalR, paint);
    }
    canvas.drawCircle(Offset(cx, cy), petalR * 0.55, paint);
  }

  @override
  bool shouldRepaint(_CloverPainter old) => old.color != color;
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({
    required this.initial,
    required this.fill,
    required this.letterColor,
    required this.onTap,
    this.photoUrl,
  });

  final String initial;
  final String? photoUrl;
  final Color fill;
  final Color letterColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fonts = KhFonts.forLocale(Localizations.localeOf(context));
    final fallback = Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      child: Text(
        initial,
        style: fonts.serifStyle(16, FontWeight.w600, height: 1).copyWith(
              color: letterColor,
            ),
      ),
    );

    Widget child = fallback;
    final url = photoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      child = ClipOval(
        child: KhNetworkImage(
          url: url,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        ),
      );
    }

    return Semantics(
      button: true,
      label: 'Profile',
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: SizedBox(width: 40, height: 40, child: Center(child: child)),
      ),
    );
  }
}

/// GL-58: surfaced when a pending guest publish couldn't auto-complete
/// (e.g. offline at the time) so the user can retry it manually.
class _RetryPublicationBanner extends StatelessWidget {
  const _RetryPublicationBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Row(
          children: [
            Icon(Icons.cloud_upload_outlined, color: tokens.gold),
            SizedBox(width: tokens.space.sm),
            Expanded(
              child: Text(
                'Your request could not be published yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(width: tokens.space.sm),
            KhButton(
              label: 'Retry',
              width: null,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
