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

/// CUS-S23 Guest Landing (`adr/0011`), Direction 1a
/// (`docs/UI-Design-Context.md` §7.2).
///
/// Cold-start surface with no live session. Not the signed-in Dashboard, and
/// no bottom nav. A Guest can browse and compose; sign-in is asked for at
/// publish.
class GuestLandingScreen extends ConsumerWidget {
  const GuestLandingScreen({super.key});

  /// Content column cap on tablet / landscape / web (§10).
  static const _maxContentWidth = 560.0;

  void _openService(BuildContext context, WidgetRef ref, RequestType type) {
    ref.read(requestCreateControllerProvider.notifier).selectType(type);
    // push (not go): Guest Landing has no prior history, so `go()` here
    // left back with nothing to pop and exited the app outright.
    context.push(RequestCreatePaths.composeFor(type));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = KhStrings.of(context);
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final typography = context.typography;

    final services = [
      _GuestService(
        type: RequestType.findOrnament,
        tileKey: const Key('guest-type-ornament'),
        tapKey: const Key('guest-service-ornament'),
        title: strings.s('service.card.ornament'),
        image: const AssetImage('assets/images/tile_find_ornament.webp'),
      ),
      _GuestService(
        type: RequestType.sellOldGold,
        tileKey: const Key('guest-type-sell-gold'),
        tapKey: const Key('guest-service-sell-gold'),
        title: strings.s('service.card.sellGold'),
        image: const AssetImage('assets/images/tile_sell_old_gold.webp'),
      ),
      _GuestService(
        type: RequestType.goldCoin,
        tileKey: const Key('guest-type-coins'),
        tapKey: const Key('guest-service-coins'),
        title: strings.s('service.card.coins'),
        image: const AssetImage('assets/images/tile_gold_coin.webp'),
      ),
      _GuestService(
        type: RequestType.goldBullion,
        tileKey: const Key('guest-type-bullion'),
        tapKey: const Key('guest-service-bullion'),
        title: strings.s('service.card.bullion'),
        image: const AssetImage('assets/images/tile_gold_bullion.webp'),
      ),
    ];

    return Scaffold(
      key: const Key('guest-landing'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GuestHeader(
                  logoLabel: strings.s('guest.title'),
                  logInLabel: strings.s('guest.logIn'),
                  onLogIn: () => context.go(AppGuards.customerOnboarding),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      tokens.space.md,
                      tokens.space.s12,
                      tokens.space.md,
                      tokens.space.xl,
                    ),
                    children: [
                      Text(
                        strings.s('guest.headline'),
                        style: typography.displayGuest,
                      ),
                      SizedBox(height: tokens.space.s6),
                      Text(
                        strings.s('guest.subhead'),
                        style: typography.bodyLoose,
                      ),
                      SizedBox(height: tokens.space.s22),
                      KhServiceGrid(
                        children: [
                          for (final service in services)
                            KhServiceCard(
                              key: service.tileKey,
                              tapKey: service.tapKey,
                              title: service.title,
                              image: service.image,
                              onTap: () =>
                                  _openService(context, ref, service.type),
                            ),
                        ],
                      ),
                      SizedBox(height: tokens.space.s22),
                      KeyedSubtree(
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
                      ),
                      SizedBox(height: tokens.space.lg),
                      Center(
                        child: TextButton(
                          key: const Key('guest-jeweller'),
                          style: TextButton.styleFrom(
                            foregroundColor: tokens.ink,
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
                            strings.s('guest.jewellerFooter'),
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

/// 60 px header: tracked brand mark at the start, "Log in" at the end.
class _GuestHeader extends StatelessWidget {
  const _GuestHeader({
    required this.logoLabel,
    required this.logInLabel,
    required this.onLogIn,
  });

  final String logoLabel;
  final String logInLabel;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      height: 60,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space.md),
        child: Row(
          children: [
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: KhBrandMark(label: logoLabel),
              ),
            ),
            SizedBox(width: tokens.space.sm),
            // Arabic "Log in" can crowd the mark at 320 px; ellipsis keeps
            // the row from overflowing.
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  key: const Key('guest-login'),
                  onPressed: onLogIn,
                  child: Text(
                    logInLabel,
                    key: const Key('guest-log-in'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _GuestService {
  const _GuestService({
    required this.type,
    required this.tileKey,
    required this.tapKey,
    required this.title,
    required this.image,
  });

  final RequestType type;
  final Key tileKey;
  final Key tapKey;
  final String title;
  final ImageProvider image;
}
