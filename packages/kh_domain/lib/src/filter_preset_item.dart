import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_preset_item.freezed.dart';
part 'filter_preset_item.g.dart';

Map<String, dynamic> _normalizeFilterPresetItemJson(Map<String, dynamic> json) {
  final createdAt =
      DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();
  return {
    ...json,
    'filters':
        (json['filters'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Saved vendor match-filter preset (CP2-F06 freezed pattern).
@freezed
abstract class FilterPresetItem with _$FilterPresetItem {
  const factory FilterPresetItem({
    required String id,
    required String name,
    @Default(<String, dynamic>{}) Map<String, dynamic> filters,
    required DateTime createdAt,
  }) = _FilterPresetItem;

  factory FilterPresetItem.fromJson(Map<String, dynamic> json) =>
      _$FilterPresetItemFromJson(_normalizeFilterPresetItemJson(json));
}
