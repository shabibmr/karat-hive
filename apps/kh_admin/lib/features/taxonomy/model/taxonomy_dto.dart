import 'package:freezed_annotation/freezed_annotation.dart';

part 'taxonomy_dto.freezed.dart';
part 'taxonomy_dto.g.dart';

/// Request DTO for creating a new Category or Region node.
@freezed
class CreateTaxonomyDto with _$CreateTaxonomyDto {
  const factory CreateTaxonomyDto({
    String? parentId,
    required String nameEn,
    required String nameAr,
    String? icon,
    @Default(0) int displayOrder,
    @Default(true) bool isActive,
  }) = _CreateTaxonomyDto;

  factory CreateTaxonomyDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTaxonomyDtoFromJson(json);
}

/// Request DTO for updating an existing Category or Region node.
@freezed
class UpdateTaxonomyDto with _$UpdateTaxonomyDto {
  const factory UpdateTaxonomyDto({
    String? parentId,
    String? nameEn,
    String? nameAr,
    String? icon,
    int? displayOrder,
    bool? isActive,
  }) = _UpdateTaxonomyDto;

  factory UpdateTaxonomyDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaxonomyDtoFromJson(json);
}
