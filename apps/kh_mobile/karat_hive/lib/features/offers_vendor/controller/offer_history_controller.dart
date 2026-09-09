import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/offer_history_repository.dart';

/// Filter state for VEN-S14 (CP6-B04.2). Outcome is client-side for the
/// terminal history list (B04.4); performance aggregates ignore it.
class OfferHistoryFilters {
  const OfferHistoryFilters({
    required this.range,
    required this.preset,
    this.requestType,
    this.categoryId,
    this.regionId,
    this.outcome,
  });

  factory OfferHistoryFilters.initial({DateTime? now}) {
    final clock = now ?? DateTime.now();
    final range = KhDateRangePicker.rangeForPreset(
      KhDateRangePreset.last30,
      now: clock,
    );
    return OfferHistoryFilters(
      range: range,
      preset: KhDateRangePreset.last30,
    );
  }

  final DateTimeRange range;
  final KhDateRangePreset preset;
  final String? requestType;
  final String? categoryId;
  final String? regionId;

  /// Terminal [OfferState.wire] value, or null for all outcomes.
  final String? outcome;

  /// Inclusive end-of-day for the selected `to` date (local calendar day).
  DateTime get toInclusive {
    final end = KhDateRangePicker.dateOnly(range.end);
    return DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
  }

  DateTime get fromStart => KhDateRangePicker.dateOnly(range.start);

  OfferHistoryFilters copyWith({
    DateTimeRange? range,
    KhDateRangePreset? preset,
    String? requestType,
    bool clearRequestType = false,
    String? categoryId,
    bool clearCategoryId = false,
    String? regionId,
    bool clearRegionId = false,
    String? outcome,
    bool clearOutcome = false,
  }) {
    return OfferHistoryFilters(
      range: range ?? this.range,
      preset: preset ?? this.preset,
      requestType:
          clearRequestType ? null : (requestType ?? this.requestType),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      regionId: clearRegionId ? null : (regionId ?? this.regionId),
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
    );
  }
}

/// Override in tests for deterministic presets (`OfferHistoryScreen.now`).
final offerHistoryClockProvider = Provider<DateTime>((_) => DateTime.now());

class OfferHistoryFiltersController
    extends AutoDisposeNotifier<OfferHistoryFilters> {
  @override
  OfferHistoryFilters build() =>
      OfferHistoryFilters.initial(now: ref.watch(offerHistoryClockProvider));

  void setDateRange(KhDateRangeSelection selection) {
    state = state.copyWith(range: selection.range, preset: selection.preset);
  }

  void setFrom(DateTime from) {
    final start = KhDateRangePicker.dateOnly(from);
    final end = state.range.end.isBefore(start) ? start : state.range.end;
    state = state.copyWith(
      range: DateTimeRange(start: start, end: KhDateRangePicker.dateOnly(end)),
      preset: KhDateRangePreset.custom,
    );
  }

  void setTo(DateTime to) {
    final end = KhDateRangePicker.dateOnly(to);
    final start = state.range.start.isAfter(end) ? end : state.range.start;
    state = state.copyWith(
      range: DateTimeRange(start: KhDateRangePicker.dateOnly(start), end: end),
      preset: KhDateRangePreset.custom,
    );
  }

  void setRequestType(String? type) => state = type == null
      ? state.copyWith(clearRequestType: true)
      : state.copyWith(requestType: type);

  void setCategoryId(String? id) => state = id == null
      ? state.copyWith(clearCategoryId: true)
      : state.copyWith(categoryId: id);

  void setRegionId(String? id) => state = id == null
      ? state.copyWith(clearRegionId: true)
      : state.copyWith(regionId: id);

  void setOutcome(String? outcome) => state = outcome == null
      ? state.copyWith(clearOutcome: true)
      : state.copyWith(outcome: outcome);

  void reset() =>
      state = OfferHistoryFilters.initial(now: ref.read(offerHistoryClockProvider));
}

final offerHistoryFiltersProvider = AutoDisposeNotifierProvider<
    OfferHistoryFiltersController, OfferHistoryFilters>(
  OfferHistoryFiltersController.new,
);

/// Loads aggregates for the current filters via [PerformanceClient].
/// Metric UI is CP6-B04.3; this provider exists so filters are live-wired.
final offerHistoryPerformanceProvider =
    FutureProvider.autoDispose<VendorPerformanceDto>((ref) async {
  final query = ref.watch(
    offerHistoryFiltersProvider.select(
      (f) => (
        from: f.fromStart,
        to: f.toInclusive,
        requestType: f.requestType,
        categoryId: f.categoryId,
        regionId: f.regionId,
      ),
    ),
  );
  final repo = ref.watch(offerHistoryRepositoryProvider);
  final r = await repo.getPerformance(
    from: query.from,
    to: query.to,
    requestType: query.requestType,
    categoryId: query.categoryId,
    regionId: query.regionId,
  );
  return r.when(ok: (v) => v, err: (f) => throw f);
});

/// Loads terminal offers for current filters via [OffersClient].
/// Outcome, categoryId, and regionId are client-side filtered per VEN-S14 / BR-008.
final rawTerminalOffersProvider =
    FutureProvider.autoDispose<List<OfferForVendor>>((ref) async {
  final query = ref.watch(
    offerHistoryFiltersProvider.select(
      (f) => (
        from: f.fromStart,
        to: f.toInclusive,
        requestType: f.requestType,
      ),
    ),
  );
  final repo = ref.watch(offerHistoryRepositoryProvider);
  final r = await repo.getTerminalOffers(
    tab: 'CLOSED',
    from: query.from,
    to: query.to,
    requestType: query.requestType,
  );
  return r.when(
    ok: (paged) => paged.items,
    err: (f) => throw f,
  );
});

final offerHistoryListProvider =
    FutureProvider.autoDispose<List<OfferForVendor>>((ref) async {
  final items = await ref.watch(rawTerminalOffersProvider.future);
  final filters = ref.watch(offerHistoryFiltersProvider);
  return items.where((offer) {
    if (filters.categoryId != null &&
        offer.requestSummary?.categoryId != filters.categoryId) {
      return false;
    }
    if (filters.regionId != null &&
        offer.requestSummary?.regionId != filters.regionId) {
      return false;
    }
    if (filters.outcome != null &&
        offer.state.wire != filters.outcome) {
      return false;
    }
    return true;
  }).toList(growable: false);
});
