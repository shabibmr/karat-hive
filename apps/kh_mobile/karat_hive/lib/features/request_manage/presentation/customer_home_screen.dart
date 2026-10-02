import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';
import '../../notifications/controller/notifications_controller.dart';
import '../../request_create/controller/request_create_controller.dart';
import '../../request_create/pending_publish_intent.dart';
import '../../request_create/routes.dart';

/// Photographic Customer Home: brand, carousel, and four request services.
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  static const _maxContentWidth = 560.0;

  void _openService(BuildContext context, WidgetRef ref, RequestType type) {
    ref.read(requestCreateControllerProvider.notifier).selectType(type);
    context.push(RequestCreatePaths.composeFor(type));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = KhStrings.of(context);
    final session = ref.watch(sessionProvider);
    final name = session is SignedIn
        ? session.customerProfile?.displayName.trim() ?? ''
        : '';
    final unread = ref.watch(unreadNotificationsProvider).value ?? false;
    final slides = [
      for (var i = 1; i <= 3; i++)
        KhHeroSlide(
          lead: s.s('cus.home.editorial.$i.a'),
          line2: s.s('cus.home.editorial.$i.b'),
          line3: s.s('cus.home.editorial.$i.c'),
          image: const AssetImage('assets/home/hero-bangle.png'),
        ),
    ];
    final services = [
      (
        type: RequestType.findOrnament,
        key: const Key('customer-type-ornament'),
        title: s.s('cus.home.service.ornament'),
        image: 'assets/home/ornament.png',
        icon: Icons.diamond_outlined,
      ),
      (
        type: RequestType.sellOldGold,
        key: const Key('customer-type-sell-gold'),
        title: s.s('cus.home.service.sellGold'),
        image: 'assets/home/sell-gold.png',
        icon: Icons.balance,
      ),
      (
        type: RequestType.goldCoin,
        key: const Key('customer-type-coins'),
        title: s.s('cus.home.service.coins'),
        image: 'assets/home/coins.png',
        icon: Icons.monetization_on_outlined,
      ),
      (
        type: RequestType.goldBullion,
        key: const Key('customer-type-bullion'),
        title: s.s('cus.home.service.bullion'),
        image: 'assets/home/bullion.png',
        icon: Icons.crop_landscape_outlined,
      ),
    ];

    return Scaffold(
      key: const Key('customer-home-screen'),
      backgroundColor: KhHomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KhBrandHeader(
                  brandLabel: s.s('guest.title'),
                  alertsLabel: s.s('shell.nav.alerts'),
                  profileLabel: s.s('shell.nav.profile'),
                  initial: name.isEmpty
                      ? null
                      : name.characters.first.toUpperCase(),
                  hasUnread: unread,
                  onAlerts: () => context.go(AppGuards.customerAlerts),
                  onProfile: () => context.go(AppGuards.customerProfile),
                ),
                Expanded(
                  child: KhPullToRefresh(
                    onRefresh: () async {
                      ref.invalidate(unreadNotificationsProvider);
                      await ref.read(unreadNotificationsProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.fromLTRB(
                        KhHomeStyle.pagePadding,
                        6,
                        KhHomeStyle.pagePadding,
                        22,
                      ),
                      children: [
                        if (ref.watch(pendingPublishIntentProvider)) ...[
                          _RetryPublicationBanner(
                            key: const Key('retry-publication-banner'),
                            onRetry: () => ref
                                .read(requestCreateControllerProvider.notifier)
                                .reconcilePendingPublish(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        KhHeroCarousel(
                          key: const Key('customer-home-hero'),
                          slides: slides,
                          editorial: true,
                          previousLabel: s.s('cus.home.previousSlide'),
                          nextLabel: s.s('cus.home.nextSlide'),
                          dotLabel: (i, n) => s
                              .s('cus.home.heroDot')
                              .replaceAll('{n}', '${i + 1}')
                              .replaceAll('{count}', '$n'),
                        ),
                        const SizedBox(height: 16),
                        KhServiceGrid(
                          maxColumns: 2,
                          equalizeHeight: false,
                          spacing: KhHomeStyle.gridGap,
                          children: [
                            for (final service in services)
                              KhServiceCard(
                                key: service.key,
                                title: service.title,
                                icon: service.icon,
                                image: AssetImage(service.image),
                                editorial: true,
                                onTap: () =>
                                    _openService(context, ref, service.type),
                              ),
                          ],
                        ),
                      ],
                    ),
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

class _RetryPublicationBanner extends StatelessWidget {
  const _RetryPublicationBanner({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = KhStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.cloud_upload_outlined, color: KhHomeStyle.gold),
            const SizedBox(width: 12),
            Expanded(child: Text(s.s('cus.home.retryPublish'))),
            const SizedBox(width: 12),
            KhButton(
              label: s.s('common.retry'),
              width: null,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
