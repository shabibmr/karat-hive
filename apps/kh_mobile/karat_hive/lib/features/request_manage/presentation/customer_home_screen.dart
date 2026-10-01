import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../request_create/controller/request_create_controller.dart';
import '../../request_create/pending_publish_intent.dart';
import '../../request_create/routes.dart';

/// CUS-S02 Customer Home / Dashboard, Direction 1a
/// (`docs/UI-Design-Context.md` §7.1).
///
/// Header (tracked KARAT HIVE · bell) → hero carousel → service grid →
/// "How this works" panel. The open-request list is not here; it lives under
/// the My Requests tab.

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  /// Content column cap on tablet / landscape / web (§10).
  static const _maxContentWidth = 560.0;

  void _openService(BuildContext context, WidgetRef ref, RequestType type) {
    ref.read(requestCreateControllerProvider.notifier).selectType(type);
    context.push(RequestCreatePaths.composeFor(type));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final s = KhStrings.of(context);

    // Jewellery photography behind the display lines (visual pass H01 / Home-1).
    const heroPhoto = AssetImage('assets/images/hero_jewellery.webp');
    final slides = [
      for (var i = 1; i <= 4; i++)
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
        title: s.s('service.card.ornament'),
        image: const AssetImage('assets/images/tile_find_ornament.webp'),
      ),
      (
        type: RequestType.sellOldGold,
        key: const Key('customer-type-sell-gold'),
        title: s.s('service.card.sellGold'),
        image: const AssetImage('assets/images/tile_sell_old_gold.webp'),
      ),
      (
        type: RequestType.goldCoin,
        key: const Key('customer-type-coins'),
        title: s.s('service.card.coins'),
        image: const AssetImage('assets/images/tile_gold_coin.webp'),
      ),
      (
        type: RequestType.goldBullion,
        key: const Key('customer-type-bullion'),
        title: s.s('service.card.bullion'),
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
                  logoLabel: s.s('guest.title'),
                  // No unread-count source on the client yet
                  // (`GET /v1/notifications/unread-count` is [PROPOSED]), so
                  // the badge stays hidden until one exists.
                  alertsLabel: s.s('shell.nav.alerts'),
                  onAlerts: () => context.go(AppGuards.customerAlerts),
                ),
                Expanded(
                  child: ListView(
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
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: tokens.space.lg,
                          bottom: tokens.space.s12,
                        ),
                        child: Semantics(
                          header: true,
                          child: Text(
                            s.s('cus.home.whatTitle'),
                            style: textTheme.headlineMedium,
                          ),
                        ),
                      ),
                      KhServiceGrid(
                        children: [
                          for (final service in services)
                            KhServiceCard(
                              key: service.key,
                              title: service.title,
                              image: service.image,
                              onTap: () =>
                                  _openService(context, ref, service.type),
                            ),
                        ],
                      ),
                      SizedBox(height: tokens.space.s22),
                      KhHowItWorksPanel(
                        key: const Key('customer-home-how'),
                        title: s.s('cus.home.howTitle'),
                        steps: [
                          KhHowStep(
                            label: s.s('cus.home.step.post'),
                            icon: Icons.post_add,
                          ),
                          KhHowStep(
                            label: s.s('cus.home.step.offers'),
                            icon: Icons.groups_outlined,
                          ),
                          KhHowStep(
                            label: s.s('cus.home.step.accept'),
                            icon: Icons.balance,
                          ),
                          KhHowStep(
                            label: s.s('cus.home.step.whatsApp'),
                            icon: Icons.handshake_outlined,
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

/// 60 px header: tracked brand mark at the start, alerts bell at the end.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.logoLabel,
    required this.alertsLabel,
    required this.onAlerts,
  });

  final String logoLabel;
  final String alertsLabel;
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      height: 60,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space.md),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: KhBrandMark(label: logoLabel),
              ),
            ),
            KhBellButton(
              key: const Key('customer-home-alerts'),
              semanticLabel: alertsLabel,
              onPressed: onAlerts,
            ),
          ],
        ),
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
