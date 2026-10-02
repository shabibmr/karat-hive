import 'package:freezed_annotation/freezed_annotation.dart';

import 'party.dart';

part 'review.freezed.dart';
part 'review.g.dart';

enum ReviewState {
  pendingModeration,
  published,
  rejected,
  redacted,
  withdrawn,
  unknown;

  static ReviewState parse(String? raw) => switch (raw) {
        'PENDING_MODERATION' => pendingModeration,
        'PUBLISHED' => published,
        'REJECTED' => rejected,
        'REDACTED' => redacted,
        'WITHDRAWN' => withdrawn,
        _ => unknown,
      };

  String get wire => switch (this) {
        pendingModeration => 'PENDING_MODERATION',
        published => 'PUBLISHED',
        rejected => 'REJECTED',
        redacted => 'REDACTED',
        withdrawn => 'WITHDRAWN',
        unknown => 'UNKNOWN',
      };
}

class _ReviewStateConverter implements JsonConverter<ReviewState, String?> {
  const _ReviewStateConverter();

  @override
  ReviewState fromJson(String? json) => ReviewState.parse(json);

  @override
  String toJson(ReviewState object) => object.wire;
}

class _PartyRoleConverter implements JsonConverter<PartyRole, String?> {
  const _PartyRoleConverter();

  @override
  PartyRole fromJson(String? json) => PartyRole.parse(json);

  @override
  String toJson(PartyRole object) => object.wire;
}

Map<String, dynamic> _normalizeReviewVendorResponseJson(
        Map<String, dynamic> json) =>
    {
      'text': json['text'] as String? ?? '',
      'state': json['state']?.toString(),
    };

@freezed
abstract class ReviewVendorResponse with _$ReviewVendorResponse {
  const factory ReviewVendorResponse({
    required String text,
    @_ReviewStateConverter() required ReviewState state,
  }) = _ReviewVendorResponse;

  factory ReviewVendorResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewVendorResponseFromJson(_normalizeReviewVendorResponseJson(json));
}

/// Peels a mistaken extra `{ data: review }` layer from double-enveloped
/// responses (controller returned `{ data }` and EnvelopeInterceptor wrapped
/// again). Prefer fixing the controller; this keeps older deployments parseable.
Map<String, dynamic> _unwrapReviewResource(Map<String, dynamic> json) {
  if (json['id'] != null) return json;
  final nested = json['data'];
  if (nested is Map) {
    return Map<String, dynamic>.from(nested);
  }
  return json;
}

Map<String, dynamic> _normalizeReviewJson(Map<String, dynamic> json) {
  final root = _unwrapReviewResource(json);
  final vr = root['vendorResponse'];
  return {
    ...root,
    'id': root['id']?.toString() ?? '',
    'connectionId': root['connectionId']?.toString() ?? '',
    'authorType': root['authorType']?.toString(),
    'rating': (root['rating'] as num?)?.toInt() ?? 0,
    'state': root['state']?.toString(),
    'vendorResponse':
        vr is Map ? Map<String, dynamic>.from(vr) : null,
    'editableUntil': (DateTime.tryParse(root['editableUntil'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0))
        .toIso8601String(),
    'createdAt': (DateTime.tryParse(root['createdAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0))
        .toIso8601String(),
    'publishedAt': root['publishedAt'] is String
        ? (DateTime.tryParse(root['publishedAt'] as String)?.toIso8601String())
        : null,
  };
}

@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required String connectionId,
    @_PartyRoleConverter() required PartyRole authorType,
    required int rating,
    @_ReviewStateConverter() required ReviewState state,
    required DateTime editableUntil,
    required DateTime createdAt,
    String? comment,
    ReviewVendorResponse? vendorResponse,
    DateTime? publishedAt,
    String? authorDisplayName,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(_normalizeReviewJson(json));
}
