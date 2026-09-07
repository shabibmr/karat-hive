// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaskedParty _$MaskedPartyFromJson(Map<String, dynamic> json) => _MaskedParty(
  role: const _UserRoleConverter().fromJson(json['role'] as String?),
  region: json['region'] as String?,
  pseudonym: json['pseudonym'] as String?,
  rating: _ratingSummaryFromJson(json['rating']),
  dealCount: (json['dealCount'] as num?)?.toInt() ?? 0,
);
