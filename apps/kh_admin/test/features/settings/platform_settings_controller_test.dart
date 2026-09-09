import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/features/settings/controller/platform_settings_controller.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';
import 'package:kh_admin/features/settings/repository/platform_settings_repository.dart';

class _FakeSettingsRepository extends PlatformSettingsRepository {
  _FakeSettingsRepository({
    List<PlatformSettingItem>? initialItems,
    this.failUpdate = false,
  })  : items = initialItems ??
            [
              PlatformSettingItem(
                key: 'request.lifetime_hours',
                value: 48,
                dataType: 'number',
                description: 'Request lifetime in hours before expiration.',
                allowedRange: const SettingAllowedRange(min: 1, max: 168),
                category: SettingCategory.lifecycle,
              ),
              PlatformSettingItem(
                key: 'offer.validity_hours_options',
                value: [12, 24, 48],
                dataType: 'number[]',
                category: SettingCategory.lifecycle,
              ),
              PlatformSettingItem(
                key: 'bullion.minimum_value_aed',
                value: 500,
                dataType: 'money',
                category: SettingCategory.limits,
              ),
              PlatformSettingItem(
                key: 'media.image.max_bytes',
                value: 5242880,
                dataType: 'number',
                category: SettingCategory.media,
              ),
            ],
        super(ApiClient());

  List<PlatformSettingItem> items;
  bool failFetch = false;
  bool failUpdate;
  String? updateErrorCode;
  String? lastUpdatedKey;
  dynamic lastUpdatedValue;
  bool? lastUpdatedConfirm;

  @override
  Future<List<PlatformSettingItem>> fetchSettings() async {
    if (failFetch) {
      throw ApiException(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Settings service unavailable',
      );
    }
    return items;
  }

  @override
  Future<PlatformSettingItem> updateSetting(
    String key,
    dynamic value, {
    bool? confirm,
  }) async {
    lastUpdatedKey = key;
    lastUpdatedValue = value;
    lastUpdatedConfirm = confirm;

    if (failUpdate) {
      throw ApiException(
        statusCode: 400,
        code: updateErrorCode ?? 'SETTING_OUT_OF_RANGE',
        message: 'Supplied value is out of allowed range.',
      );
    }

    final updated = PlatformSettingItem(
      key: key,
      value: value,
      dataType: 'number',
    );
    return updated;
  }
}

void main() {
  group('PlatformSettingsController', () {
    test('initializes and loads settings into state', () async {
      final repo = _FakeSettingsRepository();
      final controller = PlatformSettingsController(repo);

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, false);
      expect(controller.state.settings.length, 4);
      expect(controller.state.filteredSettings.length, 4);
      expect(controller.state.countByCategory(SettingCategory.lifecycle), 2);
      expect(controller.state.countByCategory(SettingCategory.limits), 1);
      expect(controller.state.countByCategory(SettingCategory.media), 1);
      expect(controller.state.pendingDecisionsCount, 1);
    });

    test('selectCategory filters settings list accordingly', () async {
      final repo = _FakeSettingsRepository();
      final controller = PlatformSettingsController(repo);
      await Future<void>.delayed(Duration.zero);

      controller.selectCategory(SettingCategory.lifecycle);
      expect(controller.state.filteredSettings.length, 2);
      expect(
        controller.state.filteredSettings.every((s) => s.category == SettingCategory.lifecycle),
        true,
      );

      controller.selectCategory(SettingCategory.limits);
      expect(controller.state.filteredSettings.length, 1);
      expect(controller.state.filteredSettings.first.key, 'bullion.minimum_value_aed');

      controller.selectCategory(null);
      expect(controller.state.filteredSettings.length, 4);
    });

    test('setSearchQuery filters settings by key and description', () async {
      final repo = _FakeSettingsRepository();
      final controller = PlatformSettingsController(repo);
      await Future<void>.delayed(Duration.zero);

      controller.setSearchQuery('bullion');
      expect(controller.state.filteredSettings.length, 1);
      expect(controller.state.filteredSettings.first.key, 'bullion.minimum_value_aed');

      controller.setSearchQuery('expiration');
      expect(controller.state.filteredSettings.length, 1);
      expect(controller.state.filteredSettings.first.key, 'request.lifetime_hours');

      controller.setSearchQuery('');
      expect(controller.state.filteredSettings.length, 4);
    });

    test('updateSetting updates state on success and sets successMessage', () async {
      final repo = _FakeSettingsRepository();
      final controller = PlatformSettingsController(repo);
      await Future<void>.delayed(Duration.zero);

      final success = await controller.updateSetting(
        'request.lifetime_hours',
        72,
        confirm: true,
      );

      expect(success, true);
      expect(repo.lastUpdatedKey, 'request.lifetime_hours');
      expect(repo.lastUpdatedValue, 72);
      expect(repo.lastUpdatedConfirm, true);

      final updated = controller.state.settings
          .firstWhere((s) => s.key == 'request.lifetime_hours');
      expect(updated.value, 72);
      expect(controller.state.successMessage, contains('updated successfully'));
      expect(controller.state.errorMessage, isNull);
    });

    test('updateSetting records error message on failure', () async {
      final repo = _FakeSettingsRepository(failUpdate: true);
      final controller = PlatformSettingsController(repo);
      await Future<void>.delayed(Duration.zero);

      final success = await controller.updateSetting(
        'request.lifetime_hours',
        999,
      );

      expect(success, false);
      expect(controller.state.errorMessage, contains('permitted allowedRange'));
      expect(controller.state.isSaving, false);

      controller.clearMessages();
      expect(controller.state.errorMessage, isNull);
    });
  });
}
