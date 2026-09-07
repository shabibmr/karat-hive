import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_media_ref.freezed.dart';
part 'request_media_ref.g.dart';

/// Media attachment reference on a vendor-facing request (CP2-F06 freezed pattern).
@freezed
abstract class RequestMediaRef with _$RequestMediaRef {
  const factory RequestMediaRef({
    @Default('') String id,
    @Default('') String key,
    @Default('image/jpeg') String contentType,
    @Default(0) int displayOrder,
    String? thumbnailUrl,
    String? displayUrl,
  }) = _RequestMediaRef;

  factory RequestMediaRef.fromJson(Map<String, dynamic> json) =>
      _$RequestMediaRefFromJson(json);
}
