import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../request_create/controller/request_create_controller.dart';
import '../../request_create/routes.dart';
import 'widgets/how_this_works.dart';

/// Guest Landing — four services, how-it-works, Log in, jeweller footer.
class GuestLandingScreen extends ConsumerWidget {
  const GuestLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final controller = ref.read(requestCreateControllerProvider.notifier);

    final cards = <_GuestTypeCardData>[
      _GuestTypeCardData(
        type: RequestType.findOrnament,
        tileKey: const Key('guest-type-ornament'),
        title: l10n?.guestTypeOrnament ?? 'Find jewellery',
        extras: [
          l10n?.guestHowItWorksOrnamentExtra ??
              'Budget and a reference photo help jewellers match what you want.',
        ],
      ),
      _GuestTypeCardData(
        type: RequestType.sellOldGold,
        tileKey: const Key('guest-type-sell-gold'),
        title: l10n?.guestTypeSellGold ?? 'Sell my gold',
        extras: [
          l10n?.guestHowItWorksSellGoldExtra ??
              'Photos must show the actual piece you are selling.',
        ],
      ),
      _GuestTypeCardData(
        type: RequestType.goldCoin,
        tileKey: const Key('guest-type-coins'),
        title: l10n?.guestTypeCoins ?? 'Coins',
        extras: [
          l10n?.guestHowItWorksCoinsExtra ??
              'Choose buy or sell, denomination, and quantity.',
        ],
      ),
      _GuestTypeCardData(
        type: RequestType.goldBullion,
        tileKey: const Key('guest-type-bullion'),
        title: l10n?.guestTypeBullion ?? 'Bullion',
        extras: [
          l10n?.guestHowItWorksBullionExtra ??
              'A minimum indicative value applies to bullion Requests.',
        ],
      ),
    ];

    return KhScaffold(
      key: const Key('guest-landing'),
      title: l10n?.guestLandingTitle ?? 'Karat Hive',
      actions: [
        TextButton(
          key: const Key('guest-login'),
          onPressed: () => context.go(AppGuards.customerOnboarding),
          child: Text(l10n?.guestLogIn ?? 'Log in'),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          for (final card in cards) ...[
            _GuestTypeCard(
              data: card,
              onTap: () {
                controller.selectType(card.type);
                context.go(RequestCreatePaths.composeFor(card.type));
              },
            ),
            SizedBox(height: tokens.space.sm),
          ],
          SizedBox(height: tokens.space.md),
          Center(
            child: TextButton(
              key: const Key('guest-jeweller'),
              onPressed: () {
                // Mid-create → Vendor signup drops the in-memory draft (GL-66).
                controller.resetFlow();
                context.go(AppGuards.register);
              },
              child: Text(
                l10n?.guestJewellerFooter ??
                    'Are you a jeweller? Register here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestTypeCardData {
  const _GuestTypeCardData({
    required this.type,
    required this.tileKey,
    required this.title,
    required this.extras,
  });

  final RequestType type;
  final Key tileKey;
  final String title;
  final List<String> extras;
}

class _GuestTypeCard extends StatelessWidget {
  const _GuestTypeCard({required this.data, required this.onTap});

  final _GuestTypeCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      key: data.tileKey,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.space.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: tokens.ink.withValues(alpha: 0.45),
                    ),
                  ],
                ),
              ),
            ),
            HowThisWorks(extras: data.extras),
          ],
        ),
      ),
    );
  }
}
