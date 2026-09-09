import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kh_admin/features/requests/model/request_enums.dart';

part 'request_list_item.freezed.dart';
part 'request_list_item.g.dart';

/// One row in `GET /v1/admin/requests` (ADM-S08).
@freezed
class RequestListItem with _$RequestListItem {
  const RequestListItem._();

  const factory RequestListItem({
    required String id,
    String? reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    required RequestType requestType,
    @JsonKey(unknownEnumValue: Direction.buy)
    required Direction direction,
    @JsonKey(unknownEnumValue: RequestState.draft)
    required RequestState state,
    @Default('Unknown Customer') String customerName,
    String? customerId,
    String? customerPhone,
    @Default('—') String categoryName,
    @Default('—') String regionName,
    double? indicativeValue,
    double? budgetMin,
    double? budgetMax,
    @Default(0) int offerCount,
    String? notes,
    String? ornamentType,
    double? weightGrams,
    String? purityKarat,
    DateTime? publishedAt,
    DateTime? createdAt,
  }) = _RequestListItem;

  factory RequestListItem.fromJson(Map<String, dynamic> json) =>
      _$RequestListItemFromJson(json);

  /// Normalizes raw API responses (handling nested customer/category/region maps and string decimals).
  factory RequestListItem.fromApiResponse(Map<String, dynamic> json) {
    final customerObj = json['customer'] ?? json['customerProfile'];
    String custName = json['customerName']?.toString() ?? '';
    String? custId = json['customerId']?.toString();
    String? custPhone = json['customerPhone']?.toString();

    if (customerObj is Map<String, dynamic>) {
      // origin/main admin list sends the raw `customerProfile` row: the name is
      // `displayName` and the phone is nested at `customerProfile.user.mobileNumber`.
      custName = customerObj['displayName']?.toString() ??
          customerObj['fullName']?.toString() ??
          customerObj['name']?.toString() ??
          customerObj['contactPersonName']?.toString() ??
          custName;
      custId ??= customerObj['id']?.toString();
      final customerUser = customerObj['user'];
      custPhone ??= (customerUser is Map<String, dynamic>
              ? customerUser['mobileNumber']?.toString()
              : null) ??
          customerObj['mobileNumber']?.toString() ??
          customerObj['phone']?.toString();
    } else if (customerObj is String && customerObj.isNotEmpty) {
      custName = customerObj;
    }
    if (custName.isEmpty) {
      final shortId = (custId ?? json['id'] ?? '').toString();
      custName = shortId.isNotEmpty
          ? 'Customer #${shortId.length > 6 ? shortId.substring(0, 6) : shortId}'
          : 'Unmasked Customer';
    }

    final categoryObj = json['category'];
    String catName = json['categoryName']?.toString() ?? '';
    if (categoryObj is Map<String, dynamic>) {
      catName = categoryObj['nameEn']?.toString() ??
          categoryObj['name']?.toString() ??
          catName;
    } else if (categoryObj is String && categoryObj.isNotEmpty) {
      catName = categoryObj;
    }
    if (catName.isEmpty) catName = '—';

    final regionObj = json['region'];
    String regName = json['regionName']?.toString() ?? '';
    if (regionObj is Map<String, dynamic>) {
      regName = regionObj['nameEn']?.toString() ??
          regionObj['name']?.toString() ??
          regName;
    } else if (regionObj is String && regionObj.isNotEmpty) {
      regName = regionObj;
    }
    if (regName.isEmpty) regName = '—';

    final map = Map<String, dynamic>.from(json);
    map['customerName'] = custName;
    if (custId != null) map['customerId'] = custId;
    if (custPhone != null) map['customerPhone'] = custPhone;
    map['categoryName'] = catName;
    map['regionName'] = regName;

    if (map['indicativeValue'] is String) {
      map['indicativeValue'] = double.tryParse(map['indicativeValue'] as String);
    } else if (map['indicativeValue'] is num) {
      map['indicativeValue'] = (map['indicativeValue'] as num).toDouble();
    }

    if (map['budgetMin'] is String) {
      map['budgetMin'] = double.tryParse(map['budgetMin'] as String);
    } else if (map['budgetMin'] is num) {
      map['budgetMin'] = (map['budgetMin'] as num).toDouble();
    }

    if (map['budgetMax'] is String) {
      map['budgetMax'] = double.tryParse(map['budgetMax'] as String);
    } else if (map['budgetMax'] is num) {
      map['budgetMax'] = (map['budgetMax'] as num).toDouble();
    }

    if (map['weightGrams'] is String) {
      map['weightGrams'] = double.tryParse(map['weightGrams'] as String);
    } else if (map['weightGrams'] is num) {
      map['weightGrams'] = (map['weightGrams'] as num).toDouble();
    }

    return RequestListItem.fromJson(map);
  }
}
