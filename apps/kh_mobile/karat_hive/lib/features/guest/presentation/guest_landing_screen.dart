import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../auth/presentation/widgets/how_this_works.dart';
import '../../request_create/controller/request_create_controller.dart';
import '../../request_create/routes.dart';

/// CUS-S23 Guest Landing (`adr/0011`).
///
/// Cold-start surface with no live session, dressed like Customer Home
/// (brand header, editorial hero, photographic service cards) but with
/// "Log in" in place of alerts/profile and no bottom nav. A Guest can browse
/// and compose; sign-in is asked for at publish.
class GuestLandingScreen extends ConsumerWidget {
  const GuestLandingScreen({super.key});

  static const _maxContentWidth = 560.0;

  void _openService(BuildContext context, WidgetRef ref, RequestType type) {
    ref.read(requestCreateControllerProvider.notifier).selectType(type);
    // push (not go): Guest Landing has no prior history, so `go()` here
    // left back with nothing to pop and exited the app outright.
    context.push(RequestCreatePaths.composeFor(type));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = KhStrings.of(context);
    final l10n = AppLocalizations.of(context);
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
        tileKey: const Key('guest-type-ornament'),
        tapKey: const Key('guest-service-ornament'),
        title: s.s('cus.home.service.ornament'),
        image: 'assets/home/ornament.png',
        icon: Icons.diamond_outlined,
      ),
      (
        type: RequestType.sellOldGold,
        tileKey: const Key('guest-type-sell-gold'),
        tapKey: const Key('guest-service-sell-gold'),
        title: s.s('cus.home.service.sellGold'),
        image: 'assets/home/sell-gold.png',
        icon: Icons.balance,
      ),
      (
        type: RequestType.goldCoin,
        tileKey: const Key('guest-type-coins'),
        tapKey: const Key('guest-service-coins'),
        title: s.s('cus.home.service.coins'),
        image: 'assets/home/coins.png',
        icon: Icons.monetization_on_outlined,
      ),
      (
        type: RequestType.goldBullion,
        tileKey: const Key('guest-type-bullion'),
        tapKey: const Key('guest-service-bullion'),
        title: s.s('cus.home.service.bullion'),
        image: 'assets/home/bullion.png',
        icon: Icons.crop_landscape_outlined,
      ),
    ];

    final howItWorks = KeyedSubtree(
      key: const Key('guest-how-it-works'),
      child: HowThisWorks(
        extras: [
          l10n?.guestHowItWorksOrnamentExtra ??
              'Budget and a reference photo help jewellers match what you want.',
          l10n?.guestHowItWorksSellGoldExtra ??
              'Photos must show the actual piece you are selling.',
          l10n?.guestHowItWorksCoinsExtra ??
              'Choose buy or sell, denomination, and quantity.',
          l10n?.guestHowItWorksBullionExtra ??
              'A minimum indicative value applies to bullion Requests.',
        ],
      ),
    );

    return Scaffold(
      key: const Key('guest-landing'),
      backgroundColor: KhHomeStyle.background,
      // Takes the slot Customer Home gives to the bottom nav.
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: KhHomeStyle.background,
          border: Border(top: BorderSide(color: KhHomeStyle.cream)),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _maxContentWidth,
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: KhHomeStyle.pagePadding,
                ),
                child: howItWorks,
              ),
            ),
          ),
        ),
      ),
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
                  trailing: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      key: const Key('guest-login'),
                      style: TextButton.styleFrom(
                        foregroundColor: KhHomeStyle.gold,
                      ),
                      onPressed: () => context.go(AppGuards.customerOnboarding),
                      // Arabic "Log in" can crowd the mark at 320 px; ellipsis
                      // keeps the row from overflowing.
                      child: Text(
                        s.s('guest.logIn'),
                        key: const Key('guest-log-in'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.fromLTRB(
                      KhHomeStyle.pagePadding,
                      6,
                      KhHomeStyle.pagePadding,
                      22,
                    ),
                    children: [
                      KhHeroCarousel(
                        key: const Key('guest-landing-hero'),
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
                              key: service.tileKey,
                              tapKey: service.tapKey,
                              title: service.title,
                              icon: service.icon,
                              image: AssetImage(service.image),
                              editorial: true,
                              onTap: () =>
                                  _openService(context, ref, service.type),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          key: const Key('guest-jeweller'),
                          style: TextButton.styleFrom(
                            foregroundColor: KhHomeStyle.ink,
                          ),
                          onPressed: () {
                            // Mid-create -> Vendor signup drops the in-memory
                            // draft (GL-66).
                            ref
                                .read(requestCreateControllerProvider.notifier)
                                .resetFlow();
                            // Vendor register requires Google sign-in first
                            // (ADR-0010).
                            context.go(AppGuards.login);
                          },
                          child: Text(
                            s.s('guest.jewellerFooter'),
                            key: const Key('guest-jeweller-register'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
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
