import 'dart:convert';

/// Setting categories for filtering and organizing platform settings.
enum SettingCategory {
  lifecycle,
  limits,
  media,
  security;

  String get displayName {
    switch (this) {
      case SettingCategory.lifecycle:
        return 'Lifecycle';
      case SettingCategory.limits:
        return 'Trading Limits';
      case SettingCategory.media:
        return 'Media & Storage';
      case SettingCategory.security:
        return 'System & Security';
    }
  }

  static SettingCategory fromKey(String key) {
    final lower = key.toLowerCase();
    if (lower.startsWith('request.lifetime') ||
        lower.startsWith('request.expiry') ||
        lower.startsWith('offer.validity') ||
        lower.startsWith('offer.default_validity') ||
        lower.startsWith('offer.max_revisions')) {
      return SettingCategory.lifecycle;
    }
    if (lower.startsWith('bullion.') ||
        lower.startsWith('request.max_concurrent') ||
        lower.startsWith('karat.') ||
        lower.startsWith('purity.')) {
      return SettingCategory.limits;
    }
    if (lower.startsWith('media.') ||
        lower.endsWith('.max_images') ||
        lower.contains('image')) {
      return SettingCategory.media;
    }
    return SettingCategory.security;
  }
}

/// Allowed range constraints for a platform setting value.
class SettingAllowedRange {
  const SettingAllowedRange({
    this.min,
    this.max,
    this.enumValues,
  });

  final num? min;
  final num? max;
  final List<String>? enumValues;

  factory SettingAllowedRange.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final rawEnum = json['enum'];
      List<String>? enumList;
      if (rawEnum is List) {
        enumList = rawEnum.map((e) => e.toString()).toList();
      }
      num? parseNum(dynamic v) {
        if (v == null) return null;
        if (v is num) return v;
        return num.tryParse(v.toString());
      }

      return SettingAllowedRange(
        min: parseNum(json['min']),
        max: parseNum(json['max']),
        enumValues: enumList,
      );
    }
    return const SettingAllowedRange();
  }

  Map<String, dynamic> toJson() {
    return {
      if (min != null) 'min': min,
      if (max != null) 'max': max,
      if (enumValues != null) 'enum': enumValues,
    };
  }

  bool get hasRestrictions =>
      min != null || max != null || (enumValues != null && enumValues!.isNotEmpty);

  /// Validates a value against min, max, and enum restrictions.
  /// Returns null if valid, or a descriptive error message if invalid.
  String? validate(dynamic val) {
    if (val == null) return null;
    if (min != null || max != null) {
      final numVal = val is num ? val : num.tryParse(val.toString());
      if (numVal != null) {
        if (min != null && numVal < min!) {
          return 'Value must be at least $min';
        }
        if (max != null && numVal > max!) {
          return 'Value must be at most $max';
        }
      }
    }
    if (enumValues != null && enumValues!.isNotEmpty) {
      final str = val.toString();
      if (!enumValues!.contains(str)) {
        return 'Value must be one of: ${enumValues!.join(', ')}';
      }
    }
    return null;
  }

  String get summary {
    final parts = <String>[];
    if (min != null && max != null) {
      parts.add('Range: $min - $max');
    } else if (min != null) {
      parts.add('Min: $min');
    } else if (max != null) {
      parts.add('Max: $max');
    }
    if (enumValues != null && enumValues!.isNotEmpty) {
      parts.add('Allowed: ${enumValues!.join(', ')}');
    }
    return parts.isEmpty ? 'No range restrictions' : parts.join(' | ');
  }
}

/// Represents an operational platform setting in the Karat Hive admin portal.
class PlatformSettingItem {
  /// Live offer-validity hours per `FR-VEN-013` / `AD-API-07`. Do not invent 72/168.
  static const List<String> offerValidityHours = ['12', '24', '48'];

  PlatformSettingItem({
    required this.key,
    required this.value,
    required this.dataType,
    this.description,
    this.allowedRange,
    this.requiresSuperAdmin = false,
    this.lastChangedByAdminId,
    this.updatedAt,
    SettingCategory? category,
  }) : category = category ?? SettingCategory.fromKey(key);

  final String key;
  final dynamic value;
  final String dataType;
  final String? description;
  final SettingAllowedRange? allowedRange;
  final bool requiresSuperAdmin;
  final String? lastChangedByAdminId;
  final DateTime? updatedAt;
  final SettingCategory category;

  /// Flags settings subject to the live offer validity architectural decision.
  bool get isOfferValidityPendingDecision =>
      key == 'offer.validity_hours_options' || key == 'offer.default_validity_hours';

  /// Client-side guard: offer validity hours are 12/24/48 only (`AD-API-07`).
  String? validateOfferValidity(dynamic val) {
    if (!isOfferValidityPendingDecision) return null;
    if (key == 'offer.default_validity_hours') {
      final str = val?.toString();
      if (str == null || !offerValidityHours.contains(str)) {
        return 'Offer validity must be 12, 24, or 48 hours (AD-API-07). 72/168 are not permitted.';
      }
      return null;
    }
    List<dynamic>? list;
    if (val is List) {
      list = val;
    }
    if (list == null) {
      return 'Offer validity options must be a JSON array of 12, 24, and/or 48.';
    }
    for (final entry in list) {
      final str = entry.toString();
      if (!offerValidityHours.contains(str)) {
        return 'Offer validity hours must be 12, 24, or 48 (AD-API-07). Do not invent 72 or 168.';
      }
    }
    return null;
  }

  /// Provides fallback descriptions for standard platform keys.
  static String defaultDescription(String key) {
    switch (key) {
      case 'request.lifetime_hours':
        return 'Request lifetime in hours before expiration (default 48h per C-07).';
      case 'offer.validity_hours_options':
        return 'Available validity options in hours that vendors may select when submitting offers.';
      case 'offer.default_validity_hours':
        return 'Default expiration window in hours applied to new vendor offers.';
      case 'bullion.minimum_value_aed':
        return 'Minimum listing threshold in AED required for bullion category requests (BR-010).';
      case 'request.max_concurrent_live':
        return 'Maximum number of concurrent active requests permitted per customer account.';
      case 'request.max_images':
        return 'Maximum number of image attachments allowed per customer request.';
      case 'offer.max_images':
        return 'Maximum number of image attachments allowed per vendor offer.';
      case 'media.image.max_bytes':
        return 'Maximum file size in bytes for uploaded image media (e.g. 5 MB).';
      case 'media.image.accepted_types':
        return 'Permitted MIME content types for uploaded images.';
      case 'karat.options':
      case 'purity.karat_list':
        return 'Official karat purity denominations recognized by the trading system.';
      case 'media.kyc.max_bytes':
        return 'Maximum file size in bytes for uploaded KYC verification documents.';
      case 'offer.max_revisions':
        return 'Maximum revision count allowed for a single vendor offer.';
      case 'goldRates.pollIntervalMinutes':
        return 'Polling frequency in minutes for indicative spot gold rates ingestion.';
      case 'goldRates.stalenessThresholdMinutes':
        return 'Elapsed threshold in minutes before gold rate data triggers a stale alert.';
      case 'goldRates.endUserDisplay':
        return 'Feature gate enabling gold rate display to retail consumers.';
      default:
        return 'Operational platform configuration parameter.';
    }
  }

  factory PlatformSettingItem.fromJson(Map<String, dynamic> json) {
    final key = json['key']?.toString() ?? '';
    final rawDesc = json['description']?.toString();
    final desc = (rawDesc != null && rawDesc.isNotEmpty)
        ? rawDesc
        : defaultDescription(key);

    final allowedRangeRaw = json['allowedRange'] ?? json['allowed_range'];
    final allowedRange = allowedRangeRaw != null
        ? SettingAllowedRange.fromJson(allowedRangeRaw)
        : null;

    final requiresSuperAdmin = json['requiresSuperAdmin'] == true ||
        json['requiresConfirmation'] == true ||
        json['requires_confirmation'] == true;

    final updatedAtRaw =
        json['updatedAt'] ?? json['updated_at'] ?? json['lastChangedAt'];
    DateTime? updatedAt;
    if (updatedAtRaw != null) {
      updatedAt = DateTime.tryParse(updatedAtRaw.toString());
    }

    final categoryStr = json['category']?.toString();
    SettingCategory? category;
    if (categoryStr != null) {
      try {
        category = SettingCategory.values.firstWhere(
          (c) => c.name.toLowerCase() == categoryStr.toLowerCase(),
        );
      } catch (_) {
        category = SettingCategory.fromKey(key);
      }
    }

    return PlatformSettingItem(
      key: key,
      value: json['value'],
      dataType: json['dataType']?.toString() ??
          json['data_type']?.toString() ??
          'string',
      description: desc,
      allowedRange: allowedRange,
      requiresSuperAdmin: requiresSuperAdmin,
      lastChangedByAdminId: json['lastChangedByAdminId']?.toString() ??
          json['last_changed_by_admin_id']?.toString() ??
          json['lastChangedBy']?.toString(),
      updatedAt: updatedAt,
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'dataType': dataType,
      if (description != null) 'description': description,
      if (allowedRange != null) 'allowedRange': allowedRange!.toJson(),
      'requiresSuperAdmin': requiresSuperAdmin,
      if (lastChangedByAdminId != null)
        'lastChangedByAdminId': lastChangedByAdminId,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'category': category.name,
    };
  }

  String get formattedValue {
    if (value == null) return 'null';
    if (value is bool) return value ? 'Enabled (true)' : 'Disabled (false)';
    if (value is List) {
      return (value as List).join(', ');
    }
    if (value is Map) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }
    return value.toString();
  }

  PlatformSettingItem copyWith({
    String? key,
    dynamic value,
    String? dataType,
    String? description,
    SettingAllowedRange? allowedRange,
    bool? requiresSuperAdmin,
    String? lastChangedByAdminId,
    DateTime? updatedAt,
    SettingCategory? category,
  }) {
    return PlatformSettingItem(
      key: key ?? this.key,
      value: value ?? this.value,
      dataType: dataType ?? this.dataType,
      description: description ?? this.description,
      allowedRange: allowedRange ?? this.allowedRange,
      requiresSuperAdmin: requiresSuperAdmin ?? this.requiresSuperAdmin,
      lastChangedByAdminId: lastChangedByAdminId ?? this.lastChangedByAdminId,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }
}
