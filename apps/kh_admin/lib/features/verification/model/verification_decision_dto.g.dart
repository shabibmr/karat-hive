// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_decision_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerifyDecisionDto _$VerifyDecisionDtoFromJson(Map<String, dynamic> json) =>
    _VerifyDecisionDto(rationale: json['rationale'] as String);

Map<String, dynamic> _$VerifyDecisionDtoToJson(_VerifyDecisionDto instance) =>
    <String, dynamic>{'rationale': instance.rationale};

_RejectDecisionDto _$RejectDecisionDtoFromJson(Map<String, dynamic> json) =>
    _RejectDecisionDto(rationale: json['rationale'] as String);

Map<String, dynamic> _$RejectDecisionDtoToJson(_RejectDecisionDto instance) =>
    <String, dynamic>{'rationale': instance.rationale};

_RequestInfoDto _$RequestInfoDtoFromJson(Map<String, dynamic> json) =>
    _RequestInfoDto(message: json['message'] as String);

Map<String, dynamic> _$RequestInfoDtoToJson(_RequestInfoDto instance) =>
    <String, dynamic>{'message': instance.message};
