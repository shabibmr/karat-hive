import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/platform/open_url.dart';
import '../../onboarding/repository/onboarding_repository.dart';
import '../controller/offer_history_controller.dart';
import '../repository/offer_history_repository.dart';

/// VEN-S14 — Offer history & performance filters (CP6-B04.2).
///
/// Metric block (B04.3), terminal history (B04.4), and CSV export (B04.5).
class OfferHistoryScreen extends ConsumerStatefulWidget {
  const OfferHistoryScreen({
    super.key,
    this.pickRange,
    this.openUrl,
  });

  /// Optional override for custom range picking (tests).
  final KhPickDateRange? pickRange;

  /// Optional override for opening external URLs (tests).
  final Future<bool> Function(String url)? openUrl;

  static const requestTypes = <RequestType>[
    RequestType.findOrnament,
    RequestType.sellOldGold,
    RequestType.goldCoin,
    RequestType.goldBullion,
  ];

  static const outcomes = <OfferState>[
    OfferState.accepted,
    OfferState.rejected,
    OfferState.expired,
    OfferState.withdrawn,
    OfferState.withdrawnBySystem,
  ];

  static String _outcomeLabel(AppLocalizations? l10n, OfferState state) {
    return switch (state) {
      OfferState.accepted => l10n?.offerStateAccepted ?? 'Accepted',
      OfferState.rejected => l10n?.offerStateRejected ?? 'Rejected',
      OfferState.expired => l10n?.offerStateExpired ?? 'Expired',
      OfferState.withdrawn => l10n?.offerStateWithdrawn ?? 'Withdrawn',
      OfferState.withdrawnBySystem => 'Withdrawn by system',
      OfferState.pending || OfferState.unknown => state.wire,
    };
  }

  @override
  ConsumerState<OfferHistoryScreen> createState() => _OfferHistoryScreenState();
}

class _OfferHistoryScreenState extends ConsumerState<OfferHistoryScreen> {
  static const _requestTypes = OfferHistoryScreen.requestTypes;
  static const _outcomes = OfferHistoryScreen.outcomes;

  bool _isExporting = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    final filters = ref.read(offerHistoryFiltersProvider);
    final repo = ref.read(offerHistoryRepositoryProvider);
    final res = await repo.exportPerformance(
      from: filters.fromStart,
      to: filters.toInclusive,
      requestType: filters.requestType,
      categoryId: filters.categoryId,
      regionId: filters.regionId,
    );
    if (!mounted) return;
    setState(() => _isExporting = false);

    await res.when(
      ok: (dto) async {
        final opener = widget.openUrl ?? openExternalUrl;
        await opener(dto.downloadUrl);
      },
      err: (failure) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.message ?? 'Export failed. Please try again.',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final filters = ref.watch(offerHistoryFiltersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final regionsAsync = ref.watch(regionsProvider);
    final perfAsync = ref.watch(offerHistoryPerformanceProvider);
    final offersAsync = ref.watch(offerHistoryListProvider);

    return KhScaffold(
      key: const Key('offer-history-screen'),
      title: 'Offer history',
      actions: [
        if (_isExporting)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  key: Key('offer-history-export-loading'),
                ),
              ),
            ),
          )
        else
          TextButton.icon(
            key: const Key('offer-history-export-button'),
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text('Export CSV'),
            onPressed: _handleExport,
          ),
      ],
      body: ListView(
        key: const Key('offer-history-filters'),
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          Text('Performance', style: theme.textTheme.titleMedium),
          SizedBox(height: tokens.space.sm),
          perfAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(
                key: Key('offer-history-performance-loading'),
              ),
            ),
            error: (err, _) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: KhInlineError(
                message: err is Failure
                    ? (err.message ?? 'Could not load performance metrics')
                    : 'Could not load performance metrics',
              ),
            ),
            data: (perf) => _PerformanceMetricsBlock(perf: perf),
          ),
          SizedBox(height: tokens.space.lg),

          Text('Filters', style: theme.textTheme.titleMedium),
          SizedBox(height: tokens.space.md),

          // SH-FND-10 — presets + custom range picker
          KhDateRangePicker(
            label: 'Date range',
            range: filters.range,
            preset: filters.preset,
            now: ref.watch(offerHistoryClockProvider),
            pickRange: widget.pickRange,
            onChanged: (selection) => ref
                .read(offerHistoryFiltersProvider.notifier)
                .setDateRange(selection),
          ),
          SizedBox(height: tokens.space.md),

          // SH-FND-09 — explicit from / to (custom refinement)
          Row(
            children: [
              Expanded(
                child: KhDateTimeField(
                  key: const Key('offer-history-from'),
                  label: 'From',
                  value: filters.range.start,
                  mode: KhDateTimeMode.dateOnly,
                  lastDate: filters.range.end,
                  onChanged: (v) => ref
                      .read(offerHistoryFiltersProvider.notifier)
                      .setFrom(v),
                ),
              ),
              SizedBox(width: tokens.space.sm),
              Expanded(
                child: KhDateTimeField(
                  key: const Key('offer-history-to'),
                  label: 'To',
                  value: filters.range.end,
                  mode: KhDateTimeMode.dateOnly,
                  firstDate: filters.range.start,
                  lastDate: ref.watch(offerHistoryClockProvider),
                  onChanged: (v) =>
                      ref.read(offerHistoryFiltersProvider.notifier).setTo(v),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.lg),

          Text(
            l10n?.requestType ?? 'Request type',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: tokens.space.xs),
          Wrap(
            spacing: tokens.space.sm,
            runSpacing: tokens.space.xs,
            children: [
              for (final type in _requestTypes)
                ChoiceChip(
                  key: Key('offer-history-type-${type.wire}'),
                  label: Text(_requestTypeLabel(l10n, type)),
                  selected: filters.requestType == type.wire,
                  onSelected: (selected) => ref
                      .read(offerHistoryFiltersProvider.notifier)
                      .setRequestType(selected ? type.wire : null),
                ),
            ],
          ),
          SizedBox(height: tokens.space.lg),

          Text(
            l10n?.category ?? 'Category',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: tokens.space.xs),
          categoriesAsync.when(
            loading: () => const LinearProgressIndicator(
              key: Key('offer-history-categories-loading'),
            ),
            error: (_, __) => Text(
              l10n?.couldNotLoadCategories ?? 'Could not load categories',
            ),
            data: (nodes) {
              final leaves = _leaves(nodes).toList(growable: false);
              final anyCategory = l10n?.anyCategory ?? 'Any category';
              return DropdownButtonFormField<String?>(
                key: ValueKey('offer-history-category-${filters.categoryId}'),
                initialValue: filters.categoryId,
                isExpanded: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: anyCategory,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(anyCategory),
                  ),
                  ...leaves.map(
                    (n) => DropdownMenuItem<String?>(
                      value: n.id,
                      child: Text(n.nameEn),
                    ),
                  ),
                ],
                onChanged: (value) => ref
                    .read(offerHistoryFiltersProvider.notifier)
                    .setCategoryId(value),
              );
            },
          ),
          SizedBox(height: tokens.space.lg),

          Text(
            l10n?.region ?? 'Region',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: tokens.space.xs),
          regionsAsync.when(
            loading: () => const LinearProgressIndicator(
              key: Key('offer-history-regions-loading'),
            ),
            error: (_, __) => Text(
              l10n?.couldNotLoadRegions ?? 'Could not load regions',
            ),
            data: (nodes) {
              final leaves = _leaves(nodes).toList(growable: false);
              final anyRegion = l10n?.anyRegion ?? 'Any region';
              return DropdownButtonFormField<String?>(
                key: ValueKey('offer-history-region-${filters.regionId}'),
                initialValue: filters.regionId,
                isExpanded: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: anyRegion,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(anyRegion),
                  ),
                  ...leaves.map(
                    (n) => DropdownMenuItem<String?>(
                      value: n.id,
                      child: Text(n.nameEn),
                    ),
                  ),
                ],
                onChanged: (value) => ref
                    .read(offerHistoryFiltersProvider.notifier)
                    .setRegionId(value),
              );
            },
          ),
          SizedBox(height: tokens.space.lg),

          Text('Outcome', style: theme.textTheme.titleSmall),
          SizedBox(height: tokens.space.xs),
          Wrap(
            spacing: tokens.space.sm,
            runSpacing: tokens.space.xs,
            children: [
              for (final state in _outcomes)
                ChoiceChip(
                  key: Key('offer-history-outcome-${state.wire}'),
                  label: Text(_outcomeLabel(l10n, state)),
                  selected: filters.outcome == state.wire,
                  onSelected: (selected) => ref
                      .read(offerHistoryFiltersProvider.notifier)
                      .setOutcome(selected ? state.wire : null),
                ),
            ],
          ),
          SizedBox(height: tokens.space.lg),

          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: const Key('offer-history-reset'),
              onPressed: () =>
                  ref.read(offerHistoryFiltersProvider.notifier).reset(),
              child: Text(l10n?.resetFilters ?? 'Reset filters'),
            ),
          ),
          SizedBox(height: tokens.space.lg),

          Text('Offer history', style: theme.textTheme.titleMedium),
          SizedBox(height: tokens.space.sm),

          offersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                  key: Key('offer-history-loading'),
                ),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: KhInlineError(
                message: err is Failure
                    ? (err.message ?? 'Could not load offer history')
                    : 'Could not load offer history',
              ),
            ),
            data: (offers) {
              if (offers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: KhEmptyView(
                    key: Key('offer-history-empty'),
                    message: 'No offers found',
                  ),
                );
              }
              return Column(
                children: [
                  for (final offer in offers)
                    Padding(
                      padding: EdgeInsets.only(bottom: tokens.space.sm),
                      child: _TerminalOfferCard(offer: offer),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static Iterable<TaxonomyNode> _leaves(List<TaxonomyNode> nodes) sync* {
    for (final node in nodes) {
      if (node.children.isEmpty) {
        yield node;
      } else {
        yield* _leaves(node.children);
      }
    }
  }

  static String _requestTypeLabel(AppLocalizations? l10n, RequestType type) {
    return switch (type) {
      RequestType.findOrnament =>
        l10n?.requestTypeFindOrnament ?? 'Find ornament',
      RequestType.sellOldGold => 'Sell old gold',
      RequestType.goldCoin => 'Gold coin',
      RequestType.goldBullion =>
        l10n?.requestTypeBullionInvestment ?? 'Gold bullion',
      RequestType.unknown => type.wire,
    };
  }

  static String _outcomeLabel(AppLocalizations? l10n, OfferState state) {
    return switch (state) {
      OfferState.accepted => l10n?.offerStateAccepted ?? 'Accepted',
      OfferState.rejected => l10n?.offerStateRejected ?? 'Rejected',
      OfferState.expired => l10n?.offerStateExpired ?? 'Expired',
      OfferState.withdrawn => l10n?.offerStateWithdrawn ?? 'Withdrawn',
      OfferState.withdrawnBySystem => 'Withdrawn by system',
      OfferState.pending || OfferState.unknown => state.wire,
    };
  }
}

class _PerformanceMetricsBlock extends StatelessWidget {
  const _PerformanceMetricsBlock({required this.perf});

  final VendorPerformanceDto perf;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                key: const Key('metric-offers-submitted'),
                label: 'Offers Submitted',
                value: '${perf.offersSubmitted}',
              ),
            ),
            SizedBox(width: tokens.space.sm),
            Expanded(
              child: _MetricCard(
                key: const Key('metric-acceptance-rate'),
                label: 'Acceptance Rate',
                value: formatAcceptanceRate(perf.acceptanceRate),
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.space.sm),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                key: const Key('metric-response-time'),
                label: 'Avg Response Time',
                value: formatResponseTime(perf.averageResponseMinutes),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: tokens.ink,
              ),
            ),
            SizedBox(height: tokens.space.xs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.ink.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatAcceptanceRate(String raw) {
  final clean = raw.trim();
  if (clean.isEmpty) return '0%';
  if (clean.endsWith('%')) return clean;
  final val = double.tryParse(clean);
  if (val == null) return clean;
  final pct = val <= 1.0 ? val * 100 : val;
  if ((pct - pct.roundToDouble()).abs() < 0.001) {
    return '${pct.round()}%';
  }
  return '${pct.toStringAsFixed(1)}%';
}

String formatResponseTime(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  }
  final hours = minutes ~/ 60;
  final remaining = minutes % 60;
  if (remaining == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remaining}m';
}

class _TerminalOfferCard extends StatelessWidget {
  const _TerminalOfferCard({required this.offer});

  final OfferForVendor offer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final summary = offer.requestSummary;
    final title = summary?.reference ??
        summary?.categoryName ??
        'Offer #${offer.id}';
    final closedAt = offer.decidedAt ?? offer.expiresAt;
    final price = double.tryParse(offer.terms.offeredPrice) ?? 0;

    final termsList = <String>[];
    if (offer.terms.makingCharges != null &&
        offer.terms.makingCharges!.isNotEmpty) {
      termsList.add('Making: AED ${offer.terms.makingCharges}');
    }
    if (offer.terms.ratePerGram != null &&
        offer.terms.ratePerGram!.isNotEmpty) {
      termsList.add('Rate: AED ${offer.terms.ratePerGram}/g');
    }
    if (offer.terms.deliveryTimeframe != null &&
        offer.terms.deliveryTimeframe!.isNotEmpty) {
      termsList.add('Delivery: ${offer.terms.deliveryTimeframe}');
    }
    if (offer.terms.warrantyTerms != null &&
        offer.terms.warrantyTerms!.isNotEmpty) {
      termsList.add('Warranty: ${offer.terms.warrantyTerms}');
    }
    if (termsList.isEmpty && offer.terms.validityHours > 0) {
      termsList.add('${offer.terms.validityHours}h validity');
    }
    if (offer.terms.vendorNote != null &&
        offer.terms.vendorNote!.isNotEmpty) {
      termsList.add(offer.terms.vendorNote!);
    }

    return Card(
      key: Key('offer-card-${offer.id}'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Container(
        key: Key('offer-history-card-${offer.id}'),
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    key: Key('offer-title-${offer.id}'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: tokens.space.xs),
                KhStatusChip(
                  key: Key('offer-status-${offer.id}'),
                  label: OfferHistoryScreen._outcomeLabel(l10n, offer.state),
                  tone: offerStateTone(offer.state),
                  compact: true,
                ),
              ],
            ),
            if (summary?.categoryName != null) ...[
              SizedBox(height: tokens.space.xs),
              Wrap(
                spacing: tokens.space.xs,
                runSpacing: tokens.space.xs,
                children: [
                  KhStatusChip(
                    key: Key('category-badge-${offer.id}'),
                    label: summary!.categoryName!,
                    tone: KhStatusTone.neutral,
                    compact: true,
                  ),
                  if (summary.customerLabel.isNotEmpty)
                    Text(
                      summary.customerLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.ink.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ],
            SizedBox(height: tokens.space.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Submitted: ${_formatDate(offer.submittedAt)}',
                    key: Key('submission-date-${offer.id}'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.ink.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Closed: ${_formatDate(closedAt)}',
                    key: Key('closed-date-${offer.id}'),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.ink.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.space.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                MoneyDisplay(
                  key: Key('offer-price-${offer.id}'),
                  amount: price,
                  highlight: true,
                ),
                if (termsList.isNotEmpty) ...[
                  SizedBox(width: tokens.space.sm),
                  Expanded(
                    child: Text(
                      termsList.join(' • '),
                      key: Key('offer-terms-${offer.id}'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.ink.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (offer.awardedElsewhere) ...[
              SizedBox(height: tokens.space.sm),
              Container(
                key: Key('awarded-elsewhere-badge-${offer.id}'),
                child: const KhStatusChip(
                  label: 'Awarded to another vendor',
                  tone: KhStatusTone.warning,
                  compact: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[(dt.month - 1).clamp(0, 11)]} ${dt.year}';
  }
}
