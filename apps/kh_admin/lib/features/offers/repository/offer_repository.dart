import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/model/offer_list_filters.dart';
import 'package:kh_admin/features/offers/model/offer_list_item.dart';
import 'package:kh_admin/features/offers/model/offer_list_page.dart';
import 'package:kh_admin/core/api/json_parse.dart';

/// Typed repository for `GET /v1/admin/offers` and `/v1/admin/offers/:id` (ADM-S10, ADM-S11).
///
/// The origin/main admin endpoints return RAW Prisma rows wrapped only by the
/// response envelope interceptor. Decimal columns serialise as STRINGS, related
/// records are nested under their Prisma relation names (`vendorProfile`,
/// `request`), and none of the derived/aggregated fields the Flutter models
/// expect are sent. Every read here is funnelled through a private normaliser
/// that reshapes the raw JSON into the model's expected shape before
/// `fromJson` runs.
class OfferRepository {
  OfferRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultPageSize = 20;

  Future<OfferListPage> fetchOffers({
    OfferListFilters filters = const OfferListFilters(),
    String? cursor,
    int limit = defaultPageSize,
  }) async {
    // origin/main `GET /v1/admin/offers` accepts ONLY `state`, `vendorId`,
    // `limit`, `cursor`. `q`, `requestType`, `minPrice`, `maxPrice` are
    // silently ignored server-side, so we send only the supported params and
    // apply the rest client-side on the returned page.
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (filters.state != null) 'state': filters.state!.apiValue,
      if (filters.vendorId != null && filters.vendorId!.isNotEmpty)
        'vendorId': filters.vendorId,
      // backend: unsupported — filters.requestType (client-side below)
      // backend: unsupported — filters.query (client-side below)
      // backend: unsupported — filters.minPrice / filters.maxPrice (client-side below)
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/offers',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(_normalizeOfferListRow)
        .map(OfferListItem.fromJson)
        .where((item) => _matchesClientFilters(item, filters))
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    final hasMore = hasMoreFromCursor(nextCursor);

    return OfferListPage(
      items: items,
      nextCursor: hasMore ? nextCursor : null,
      hasMore: hasMore,
      // backend: unsupported — no total count is ever sent.
      totalCount: null,
    );
  }

  Future<OfferDetail> fetchOfferDetail(String offerId) async {
    final response = await _apiClient.get('/v1/admin/offers/$offerId');
    final raw = Map<String, dynamic>.from(response as Map<String, dynamic>);

    // internalNotes has no source on the offer row — merge from the notes route.
    List<Map<String, dynamic>> notes = const [];
    try {
      final notesResponse =
          await _apiClient.get('/v1/admin/offers/$offerId/notes');
      if (notesResponse is List) {
        notes = notesResponse
            .whereType<Map<String, dynamic>>()
            .map(_normalizeNote)
            .toList(growable: false);
      }
    } on Object {
      // Notes are supplementary; a failure here must not break the detail view.
      notes = const [];
    }

    final normalized = _normalizeOfferDetail(raw)..['internalNotes'] = notes;
    return OfferDetail.fromJson(normalized);
  }

  Future<OfferInternalNoteItem> addNote(
    String offerId, {
    required String note,
  }) async {
    // origin/main body schema is `{ text }` only.
    final response = await _apiClient.post(
      '/v1/admin/offers/$offerId/notes',
      data: {'text': note},
    );

    if (response is Map<String, dynamic>) {
      return OfferInternalNoteItem.fromJson(_normalizeNote(response));
    }

    return OfferInternalNoteItem(
      id: 'note-${DateTime.now().millisecondsSinceEpoch}',
      author: 'Admin',
      text: note,
      createdAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Normalisers — raw origin/main Prisma JSON -> model-shaped JSON
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _normalizeOfferListRow(Map<String, dynamic> raw) {
    final vendorProfile = asMap(raw['vendorProfile']);
    final request = asMap(raw['request']);

    return <String, dynamic>{
      'id': raw['id'],
      'reference': raw['reference'],
      'requestId': raw['requestId'],
      'requestReference': request['reference'],
      'requestType': request['requestType'],
      'vendorId': raw['vendorProfileId'],
      'vendorName': _vendorName(vendorProfile),
      'offeredPrice': toDouble(raw['offeredPrice']),
      'makingCharges': toDoubleOrNull(raw['makingCharges']),
      'ratePerGram': toDoubleOrNull(raw['ratePerGram']),
      'state': raw['state'],
      'submittedAt': raw['submittedAt'] ?? raw['createdAt'],
      'expiresAt': raw['expiresAt'],
      // Not sent by the backend — let the presentation derive from state.
      'outcome': null,
    };
  }

  Map<String, dynamic> _normalizeOfferDetail(Map<String, dynamic> raw) {
    final vendorProfile = asMap(raw['vendorProfile']);
    final vendorUser = asMap(vendorProfile['user']);
    final request = asMap(raw['request']);
    final customerProfile = asMap(request['customerProfile']);
    final customerUser = asMap(customerProfile['user']);

    return <String, dynamic>{
      'id': raw['id'],
      'reference': raw['reference'],
      'state': raw['state'],
      'offeredPrice': toDouble(raw['offeredPrice']),
      'makingCharges': toDoubleOrNull(raw['makingCharges']),
      'ratePerGram': toDoubleOrNull(raw['ratePerGram']),
      // Derived pricing fields are absent on the raw row; the model getters
      // (calculatedGoldPrice / calculatedVat / calculatedTotal) fall back.
      'goldPrice': null,
      'vat': null,
      'totalAmount': null,
      'deliveryTimeframe': raw['deliveryTimeframe'],
      'warrantyTerms': raw['warrantyTerms'],
      'vendorNote': raw['vendorNote'],
      'validityHours': raw['validityHours'],
      'expiresAt': raw['expiresAt'],
      'submittedAt': raw['submittedAt'] ?? raw['createdAt'],
      'decidedAt': raw['decidedAt'],
      'declineReason': raw['declineReason'],
      'revisionCount': raw['revisionCount'] ?? 0,
      // No winning-offer join on the raw row.
      'winningOfferId': null,
      'winningOfferReference': null,
      'winningOfferPrice': null,
      'winningVendorName': null,
      'parentRequest': request.isEmpty
          ? null
          : <String, dynamic>{
              'id': request['id'],
              'reference': request['reference'],
              'requestType': request['requestType'],
              'customerName': customerProfile['displayName'] ??
                  customerUser['email'] ??
                  customerUser['mobileNumber'],
              'customerMobile': customerUser['mobileNumber'],
              'customerEmail': customerUser['email'],
              'categoryName': null,
              'regionName': null,
              'indicativeValue': toDoubleOrNull(request['indicativeValue']),
              'notes': request['notes'],
            },
      'vendor': vendorProfile.isEmpty
          ? null
          : <String, dynamic>{
              'id': vendorProfile['id'],
              'legalBusinessName': _vendorName(vendorProfile),
              'tradingName': vendorProfile['tradingName'],
              'tradeLicenceNumber': vendorProfile['tradeLicenceNumber'],
              'contactPersonName': vendorProfile['contactPersonName'],
              'mobileNumber': vendorUser['mobileNumber'],
              'email': vendorUser['email'] ?? vendorProfile['businessEmail'],
              'rating': toDoubleOrNull(vendorProfile['aggregateRating']),
              'completedDeals': vendorProfile['offersAcceptedCount'],
            },
      // Attachments are still a separate media projection.
      'attachments': const <dynamic>[],
      'stateTransitions': _normalizeTransitions(
        raw['stateTransitions'] ?? raw['transitions'],
      ),
      'revisions': _normalizeRevisions(raw['revisions']),
      // Replaced by the caller after the notes fetch.
      'internalNotes': const <dynamic>[],
    };
  }

  List<Map<String, dynamic>> _normalizeRevisions(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((row) {
      // Prefer typed projection columns (ADM-C-73); fall back to the
      // `previousTerms` JSON blob of the terms *before* the revision.
      final prev = asMap(row['previousTerms']);
      return <String, dynamic>{
        'revisionNumber': row['revisionNumber'],
        'revisedAt': row['revisedAt'],
        'offeredPrice': toDouble(row['offeredPrice'] ?? prev['offeredPrice']),
        'makingCharges':
            toDoubleOrNull(row['makingCharges'] ?? prev['makingCharges']),
        'ratePerGram': toDoubleOrNull(row['ratePerGram'] ?? prev['ratePerGram']),
        'deliveryTimeframe':
            row['deliveryTimeframe'] ?? prev['deliveryTimeframe'],
        'vendorNote': row['vendorNote'] ?? prev['vendorNote'],
        'changeSummary': row['changeSummary'],
      };
    }).toList(growable: false);
  }

  List<Map<String, dynamic>> _normalizeTransitions(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((row) {
      return <String, dynamic>{
        'fromState': row['fromState'],
        'toState': row['toState'] ?? row['state'],
        'transitionedAt':
            row['transitionedAt'] ?? row['timestamp'] ?? row['occurredAt'],
        'actor': row['actor'] ?? row['actorName'] ?? row['actorType'],
        'reason': row['reason'] ?? row['notes'],
      };
    }).toList(growable: false);
  }

  Map<String, dynamic> _normalizeNote(Map<String, dynamic> raw) {
    // POST create response: { id, entityType, entityId, text, authorAdminId,
    //   createdAt } — NO `author`.
    // GET list response: each note additionally has `author: { displayName }`.
    final author = raw['author'];
    String? authorName;
    if (author is Map) {
      authorName = author['displayName']?.toString();
    } else if (author is String) {
      authorName = author;
    }
    authorName ??= raw['authorAdminId']?.toString();

    return <String, dynamic>{
      'id': raw['id'],
      'author': authorName ?? 'Admin',
      'text': raw['text'],
      'createdAt': raw['createdAt'],
    };
  }

  bool _matchesClientFilters(OfferListItem item, OfferListFilters filters) {
    if (filters.requestType != null &&
        item.requestType != filters.requestType) {
      return false;
    }
    if (filters.minPrice != null && item.offeredPrice < filters.minPrice!) {
      return false;
    }
    if (filters.maxPrice != null && item.offeredPrice > filters.maxPrice!) {
      return false;
    }
    final q = filters.query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final haystack = [
        item.reference,
        item.requestReference,
        item.vendorName,
        item.vendorId,
        item.id,
      ].whereType<String>().map((s) => s.toLowerCase());
      if (!haystack.any((s) => s.contains(q))) return false;
    }
    return true;
  }

  String _vendorName(Map<String, dynamic> vendorProfile) {
    final legal = vendorProfile['legalBusinessName']?.toString();
    if (legal != null && legal.isNotEmpty) return legal;
    final trading = vendorProfile['tradingName']?.toString();
    if (trading != null && trading.isNotEmpty) return trading;
    return 'Unknown vendor';
  }



}

final Provider<OfferRepository> offerRepositoryProvider =
    Provider<OfferRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OfferRepository(apiClient);
});
