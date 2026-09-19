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
/// Cold-start surface with no live session. Not the signed-in Dashboard.
class GuestLandingScreen extends ConsumerWidget {
  const GuestLandingScreen({super.key});

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
    final theme = Theme.of(context);

    final services = [
      _GuestServiceData(
        type: RequestType.findOrnament,
        tileKey: const Key('guest-type-ornament'),
        serviceKey: const Key('guest-service-ornament'),
        title: strings.s('guest.service.ornament'),
        subtitle: 'Bespoke & catalog',
        icon: Icons.diamond_outlined,
      ),
      _GuestServiceData(
        type: RequestType.sellOldGold,
        tileKey: const Key('guest-type-sell-gold'),
        serviceKey: const Key('guest-service-sell-gold'),
        title: strings.s('guest.service.sellGold'),
        subtitle: 'Instant jeweller bids',
        icon: Icons.balance_rounded,
      ),
      _GuestServiceData(
        type: RequestType.goldCoin,
        tileKey: const Key('guest-type-coins'),
        serviceKey: const Key('guest-service-coins'),
        title: strings.s('guest.service.coins'),
        subtitle: 'Standard weights',
        icon: Icons.monetization_on_outlined,
      ),
      _GuestServiceData(
        type: RequestType.goldBullion,
        tileKey: const Key('guest-type-bullion'),
        serviceKey: const Key('guest-service-bullion'),
        title: strings.s('guest.service.bullion'),
        subtitle: '24K investment bars',
        icon: Icons.crop_landscape_rounded,
      ),
    ];

    return KhScaffold(
      key: const Key('guest-landing'),
      title: strings.s('guest.title'),
      actions: [
        TextButton(
          key: const Key('guest-login'),
          onPressed: () => context.go(AppGuards.customerOnboarding),
          child: Text(
            strings.s('guest.logIn'),
            key: const Key('guest-log-in'),
          ),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.space.md,
          tokens.space.md,
          tokens.space.md,
          tokens.space.xl,
        ),
        children: [
          Text(
            strings.s('guest.headline'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.space.xs),
          Text(
            strings.s('guest.subhead'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.ink.withValues(alpha: 0.65),
            ),
          ),
          SizedBox(height: tokens.space.lg),

          // 2x2 Grid of Request Types
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: tokens.space.sm,
            mainAxisSpacing: tokens.space.sm,
            childAspectRatio: 1.45,
            children: [
              for (final service in services)
                _GuestServiceTile(
                  data: service,
                  onTap: () => _openService(context, ref, service.type),
                ),
            ],
          ),
          SizedBox(height: tokens.space.lg),

          // How this works
          Material(
            key: const Key('guest-how-it-works'),
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.md),
              side: BorderSide(
                color: tokens.ink.withValues(alpha: 0.12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space.sm),
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
          ),
          SizedBox(height: tokens.space.lg),

          Center(
            child: TextButton(
              key: const Key('guest-jeweller'),
              onPressed: () {
                // Mid-create -> Vendor signup drops the in-memory draft (GL-66).
                ref.read(requestCreateControllerProvider.notifier).resetFlow();
                // Vendor register requires Google sign-in first (ADR-0010).
                context.go(AppGuards.login);
              },
              child: Text(
                strings.s('guest.jewellerFooter'),
                key: const Key('guest-jeweller-register'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
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

class _GuestServiceData {
  const _GuestServiceData({
    required this.type,
    required this.tileKey,
    required this.serviceKey,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final RequestType type;
  final Key tileKey;
  final Key serviceKey;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _GuestServiceTile extends StatelessWidget {
  const _GuestServiceTile({
    required this.data,
    required this.onTap,
  });

  final _GuestServiceData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Material(
      key: data.tileKey,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(
          color: tokens.ink.withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        key: data.serviceKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: tokens.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(data.icon, color: tokens.gold, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.ink.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
