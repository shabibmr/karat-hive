import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';

final platformSettingsRepositoryProvider =
    Provider<PlatformSettingsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PlatformSettingsRepository(client);
});

/// Repository for managing global platform configuration settings (`/v1/admin/settings`).
class PlatformSettingsRepository {
  PlatformSettingsRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches all operational platform settings from `GET /v1/admin/settings`.
  Future<List<PlatformSettingItem>> fetchSettings() async {
    final response = await _apiClient.getCollection('/v1/admin/settings');

    return response.items
        .whereType<Map<String, dynamic>>()
        .map(PlatformSettingItem.fromJson)
        .map(_enrichOfferValidity)
        .toList(growable: false);
  }

  /// Updates a platform setting key through `PATCH /v1/admin/settings/:key`.
  ///
  /// Sensitive commercial-impact parameters accept [confirm] (`true`) for Super-Admin
  /// confirmation. Throws [ApiException] if out of allowed range (`SETTING_OUT_OF_RANGE`).
  Future<PlatformSettingItem> updateSetting(
    String key,
    dynamic value, {
    bool? confirm,
  }) async {
    final body = <String, dynamic>{
      'value': value,
      if (confirm != null) 'confirm': confirm,
    };

    final response = await _apiClient.patch(
      '/v1/admin/settings/$key',
      data: body,
    );

    if (response is Map<String, dynamic>) {
      return _enrichOfferValidity(
        PlatformSettingItem.fromJson(_unwrapEntity(response)),
      );
    }

    return _enrichOfferValidity(
      PlatformSettingItem(
        key: key,
        value: value,
        dataType: _inferDataType(value),
      ),
    );
  }

  PlatformSettingItem _enrichOfferValidity(PlatformSettingItem item) {
    if (!item.isOfferValidityPendingDecision) return item;
    if (item.key == 'offer.default_validity_hours' &&
        (item.allowedRange == null ||
            item.allowedRange!.enumValues == null ||
            item.allowedRange!.enumValues!.isEmpty)) {
      return item.copyWith(
        allowedRange: const SettingAllowedRange(
          enumValues: PlatformSettingItem.offerValidityHours,
        ),
      );
    }
    return item;
  }

  Map<String, dynamic> _unwrapEntity(Map<String, dynamic> response) {
    if (response['data'] is Map<String, dynamic> &&
        response['key'] == null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    return response;
  }

  String _inferDataType(dynamic value) {
    if (value is bool) return 'boolean';
    if (value is num) return 'number';
    if (value is List) return 'json';
    if (value is Map) return 'json';
    return 'string';
  }
}
