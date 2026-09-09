import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';

/// Codec for encoding/decoding announcement query state (TR-S1-26f / ADM-SMP-63).
class AnnouncementQueryParamsCodec extends QueryParamsCodec<AnnouncementFilters> {
  const AnnouncementQueryParamsCodec();

  @override
  AnnouncementFilters decodeFilters(Map<String, String> query) {
    final q = query['q'];
    return AnnouncementFilters(
      status: AnnouncementStatus.fromWire(query['status']),
      audienceType: AudienceType.fromWire(query['audienceType']),
      query: (q == null || q.isEmpty) ? '' : q,
    );
  }

  @override
  Map<String, String> encodeFilters(AnnouncementFilters filters) {
    final params = <String, String>{};
    if (filters.status != null) {
      params['status'] = filters.status!.wireValue;
    }
    if (filters.audienceType != null) {
      params['audienceType'] = filters.audienceType!.wireValue;
    }
    if (filters.query.isNotEmpty) {
      params['q'] = filters.query;
    }
    return params;
  }
}

/// Announcement query state encoded in URL query parameters.
class AnnouncementQueryParams {
  static const codec = AnnouncementQueryParamsCodec();

  const AnnouncementQueryParams({
    this.status,
    this.audienceType,
    this.query,
    this.cursor,
    this.selectedId,
  });

  final AnnouncementStatus? status;
  final AudienceType? audienceType;
  final String? query;
  final String? cursor;
  final String? selectedId;

  factory AnnouncementQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return AnnouncementQueryParams(
      status: state.filters.status,
      audienceType: state.filters.audienceType,
      query: state.filters.query.isEmpty ? null : state.filters.query,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory AnnouncementQueryParams.fromState(GoRouterState state) =>
      AnnouncementQueryParams.fromUri(state.uri);

  factory AnnouncementQueryParams.fromFilters(
    AnnouncementFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return AnnouncementQueryParams(
      status: filters.status,
      audienceType: filters.audienceType,
      query: filters.query.isEmpty ? null : filters.query,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  AnnouncementFilters toFilters() {
    return AnnouncementFilters(
      status: status,
      audienceType: audienceType,
      query: query ?? '',
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<AnnouncementFilters>(
        filters: toFilters(),
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }
}

/// Extension on [BuildContext] for updating announcement query parameters.
extension AnnouncementQueryNavigation on BuildContext {
  void updateAnnouncementQuery(
    AnnouncementFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      AnnouncementQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}
