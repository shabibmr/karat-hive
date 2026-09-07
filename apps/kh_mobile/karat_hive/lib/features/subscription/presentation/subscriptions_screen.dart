import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/platform/open_url.dart';
import '../controller/subscription_controller.dart';

/// VEN-S22 — Vendor Subscriptions & Entitlements Screen.
///
/// Per AD-API-04: Subscriptions are read-only in the Vendor mobile app.
/// Upgrade/subscribe actions deep link to platform-config support/contact URL,
/// never initiating in-app purchases or mutations.
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  static const List<String> allTypes = [
    'FIND_ORNAMENT',
    'CUSTOM_DESIGN',
    'BULLION',
    'REPAIR_RESIZE',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(subscriptionsListProvider);
    final configAsync = ref.watch(platformConfigProvider);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('subscriptions-screen'),
      appBar: AppBar(
        title: Text(l10n?.subscriptionsTitle ?? 'Subscriptions & Entitlements'),
      ),
      body: subsAsync.when(
        loading: () => const Center(child: KhLoadingView()),
        error: (err, _) => Center(
          child: KhErrorView(
            message: l10n?.couldNotLoadSubscriptionDetails ??
                'Could not load subscription details.',
            onRetry: () {
              ref.invalidate(subscriptionsListProvider);
              ref.invalidate(platformConfigProvider);
            },
          ),
        ),
        data: (activeSubs) {
          final subMap = {for (final s in activeSubs) s.requestType: s};
          final contactUrl = configAsync.valueOrNull?.subscriptionContactUrl ??
              'https://karathive.ae/subscriptions';

          return ListView(
            padding: EdgeInsets.all(tokens.space.md),
            children: [
              // Header info banner
              Container(
                padding: EdgeInsets.all(tokens.space.md),
                decoration: BoxDecoration(
                  color: tokens.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                  border: Border.all(color: tokens.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: tokens.gold, size: 28),
                    SizedBox(width: tokens.space.sm),
                    Expanded(
                      child: Text(
                        l10n?.subscriptionsRequirementBanner ??
                            'Each request category requires an active type subscription to receive matches and submit offers (BR-002).',
                        style: TextStyle(fontSize: 13, color: tokens.ink),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.space.md),

              Text(
                l10n?.categoryEntitlements ?? 'Category Entitlements',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: tokens.space.sm),

              // 4 Request types cards
              ...allTypes.map((type) {
                final sub = subMap[type];
                return _SubscriptionCard(
                  requestType: type,
                  item: sub,
                );
              }),

              SizedBox(height: tokens.space.lg),

              // Contact support / upgrade — deep link only (AD-API-04)
              KhButton(
                key: const Key('subscriptions-contact-cta'),
                label: l10n?.manageSubscriptionsContact ??
                    'Manage Subscriptions / Contact Support',
                onPressed: () async {
                  final opened = await openExternalUrl(contactUrl);
                  if (!context.mounted) return;
                  if (!opened) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.couldNotOpenUrl(contactUrl) ??
                              'Could not open $contactUrl',
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: tokens.space.sm),
              Center(
                child: Text(
                  l10n?.subscriptionChangesHandled ??
                      'Subscription changes are handled by Karat Hive account management.',
                  style: TextStyle(
                    fontSize: 11,
                    color: tokens.ink.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.requestType,
    required this.item,
  });

  final String requestType;
  final VendorSubscriptionItem? item;

  String _displayName(AppLocalizations? l10n) {
    return switch (requestType) {
      'FIND_ORNAMENT' =>
        l10n?.requestTypeFindOrnament ?? 'Find Ornament',
      'CUSTOM_DESIGN' =>
        l10n?.requestTypeCustomDesign ?? 'Custom Design',
      'BULLION' =>
        l10n?.requestTypeBullionInvestment ?? 'Bullion & Investment',
      'REPAIR_RESIZE' =>
        l10n?.requestTypeRepairResize ?? 'Repair & Resize',
      _ => requestType.replaceAll('_', ' '),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final state = item?.state ?? 'NONE';
    final isActive = state == 'ACTIVE';
    final isGrace = state == 'GRACE';
    final isExpired = state == 'EXPIRED' || state == 'LAPSED';

    final displayName = _displayName(l10n);

    final icon = switch (requestType) {
      'FIND_ORNAMENT' => Icons.diamond_outlined,
      'CUSTOM_DESIGN' => Icons.brush_outlined,
      'BULLION' => Icons.view_in_ar_outlined,
      'REPAIR_RESIZE' => Icons.build_outlined,
      _ => Icons.category_outlined,
    };

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: tokens.space.sm),
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(
          color: isActive
              ? tokens.success.withValues(alpha: 0.4)
              : isGrace
                  ? tokens.gold
                  : tokens.ink.withValues(alpha: 0.12),
          width: isActive || isGrace ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: tokens.gold, size: 24),
                SizedBox(width: tokens.space.sm),
                Expanded(
                  child: Text(
                    displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SubscriptionBadge(state: state),
              ],
            ),
            SizedBox(height: tokens.space.sm),

            if (item != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.planRate ?? 'Plan Rate:',
                    style: TextStyle(
                      fontSize: 13,
                      color: tokens.ink.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    l10n?.aedPerMonth(item!.priceAed) ??
                        'AED ${item!.priceAed} / month',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (item!.renewalDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.nextRenewal ?? 'Next Renewal:',
                      style: TextStyle(
                        fontSize: 12,
                        color: tokens.ink.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      item!.renewalDate!.toLocal().toString().split(' ').first,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
              if (isGrace && item!.graceEndsAt != null) ...[
                SizedBox(height: tokens.space.xs),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: tokens.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                  child: Text(
                    l10n?.gracePeriodActiveUntil(
                          item!.graceEndsAt!
                              .toLocal()
                              .toString()
                              .split(' ')
                              .first,
                        ) ??
                        'Grace period active until ${item!.graceEndsAt!.toLocal().toString().split(' ').first}. Renew now to avoid losing matching eligibility.',
                    style: TextStyle(
                      fontSize: 12,
                      color: tokens.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              if (isExpired) ...[
                SizedBox(height: tokens.space.xs),
                Text(
                  l10n?.subscriptionExpiredPaused ??
                      'Subscription expired. Matching requests for this category are currently paused.',
                  style: TextStyle(
                    fontSize: 12,
                    color: tokens.danger,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ] else ...[
              Text(
                l10n?.noActiveSubscription ??
                    'No active subscription. You will not receive matches for this category.',
                style: TextStyle(
                  fontSize: 12,
                  color: tokens.ink.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
