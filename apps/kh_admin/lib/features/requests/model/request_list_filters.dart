import 'package:freezed_annotation/freezed_annotation.dart';

import 'request_enums.dart';

part 'request_list_filters.freezed.dart';

/// Filter state for ADM-S08 Request List screen.
@freezed
class RequestListFilters with _$RequestListFilters {
  const factory RequestListFilters({
    @Default('') String query,
    RequestType? requestType,
    Direction? direction,
    RequestState? state,
    String? categoryId,
    String? regionId,
    @Default(false) bool zeroOffersOnly,
    double? minValue,
    double? maxValue,
  }) = _RequestListFilters;
}
