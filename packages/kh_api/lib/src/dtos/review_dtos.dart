import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_dtos.freezed.dart';
part 'review_dtos.g.dart';

Map<String, dynamic> _normalizeReviewJson(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'] as String,
      'connectionId': json['connectionId'] as String? ?? '',
      'authorType': json['authorType'] as String? ?? 'CUSTOMER',
      'rating': json['rating'] as int? ?? 0,
      'state': json['state'] as String? ?? '',
    };

/// `review.presenter.ts` `ReviewView`. Backs `CUS-S18` and `GET /v1/me/reviews`.
@freezed
abstract class ReviewDto with _$ReviewDto {
  const factory ReviewDto({
    required String id,
    required String connectionId,
    required String authorType, // CUSTOMER | VENDOR
    String? authorDisplayName,
    required int rating,
    String? comment,
    required String state,
    ReviewResponseDto? vendorResponse,
    required DateTime editableUntil,
    required DateTime createdAt,
    DateTime? publishedAt,
  }) = _ReviewDto;

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(_normalizeReviewJson(json));
}

Map<String, dynamic> _normalizeReviewResponseJson(Map<String, dynamic> json) => {
      'text': json['text'] as String? ?? '',
      'state': json['state'] as String? ?? '',
    };

@freezed
abstract class ReviewResponseDto with _$ReviewResponseDto {
  const factory ReviewResponseDto({
    required String text,
    required String state,
  }) = _ReviewResponseDto;

  factory ReviewResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewResponseDtoFromJson(_normalizeReviewResponseJson(json));
}
