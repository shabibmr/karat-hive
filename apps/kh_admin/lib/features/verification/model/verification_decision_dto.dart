import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_decision_dto.freezed.dart';
part 'verification_decision_dto.g.dart';

/// Body for `POST /v1/admin/vendors/{id}/verify`.
@freezed
class VerifyDecisionDto with _$VerifyDecisionDto {
  const factory VerifyDecisionDto({
    required String rationale,
  }) = _VerifyDecisionDto;

  factory VerifyDecisionDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyDecisionDtoFromJson(json);
}

/// Body for `POST /v1/admin/vendors/{id}/reject`.
@freezed
class RejectDecisionDto with _$RejectDecisionDto {
  const factory RejectDecisionDto({
    required String rationale,
  }) = _RejectDecisionDto;

  factory RejectDecisionDto.fromJson(Map<String, dynamic> json) =>
      _$RejectDecisionDtoFromJson(json);
}

/// Body for `POST /v1/admin/vendors/{id}/request-info`.
@freezed
class RequestInfoDto with _$RequestInfoDto {
  const factory RequestInfoDto({
    required String message,
  }) = _RequestInfoDto;

  factory RequestInfoDto.fromJson(Map<String, dynamic> json) =>
      _$RequestInfoDtoFromJson(json);
}
