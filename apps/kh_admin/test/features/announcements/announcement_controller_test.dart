import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/announcements/controller/announcement_controller.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/model/announcement_page.dart';
import 'package:kh_admin/features/announcements/model/create_announcement_dto.dart';
import 'package:kh_admin/features/announcements/repository/announcement_repository.dart';

class _MockAnnouncementRepository extends AnnouncementRepository {
  _MockAnnouncementRepository() : super(ApiClient());

  AnnouncementFilters? lastFilters;
  String? lastCursor;
  int fetchCount = 0;
  CreateAnnouncementDto? createdDto;
  String? cancelledId;
  bool shouldFailCreate = false;
  bool shouldFailCancel = false;

  @override
  Future<AnnouncementPage> fetchAnnouncements({
    AnnouncementFilters filters = const AnnouncementFilters(),
    String? cursor,
    int limit = AnnouncementRepository.defaultLimit,
  }) async {
    fetchCount++;
    lastFilters = filters;
    lastCursor = cursor;

    return AnnouncementPage(
      items: [
        AnnouncementItem(
          id: 'ann-1',
          titleEn: 'System Update',
          titleAr: 'تحديث النظام',
          bodyEn: 'New features available',
          bodyAr: 'ميزات جديدة متاحة',
          audience: const {'userType': 'ALL'},
          channels: const AnnouncementChannels(inApp: true),
          critical: false,
          scheduledFor: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime(2026, 9, 1, 10, 0),
        ),
      ],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<AnnouncementItem> createAnnouncement(CreateAnnouncementDto dto) async {
    if (shouldFailCreate) {
      throw Exception('Create announcement failed');
    }
    createdDto = dto;
    return AnnouncementItem(
      id: 'ann-new',
      titleEn: dto.titleEn,
      titleAr: dto.titleAr,
      bodyEn: dto.bodyEn,
      bodyAr: dto.bodyAr,
      audience: dto.audience,
      channels: AnnouncementChannels.fromJson(dto.channels),
      critical: dto.critical,
      scheduledFor: dto.scheduledFor,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AnnouncementItem> cancelAnnouncement(String id) async {
    if (shouldFailCancel) {
      throw Exception('Cancel announcement failed');
    }
    cancelledId = id;
    return AnnouncementItem(
      id: id,
      titleEn: 'Cancelled Title',
      titleAr: 'عنوان ملغى',
      bodyEn: 'Cancelled body',
      bodyAr: 'نص ملغى',
      audience: const {},
      channels: const AnnouncementChannels(),
      critical: false,
      cancelledAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}

Future<void> _settle(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!container.read(announcementListControllerProvider).isLoading) return;
  }
  fail('AnnouncementListController did not finish loading');
}

void main() {
  late ProviderContainer container;
  late _MockAnnouncementRepository mockRepository;

  setUp(() {
    mockRepository = _MockAnnouncementRepository();
    container = ProviderContainer(
      overrides: [
        announcementRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AnnouncementListController', () {
    test('initializes and loads items', () async {
      await _settle(container);

      final state = container.read(announcementListControllerProvider);
      expect(state.isLoading, false);
      expect(state.items.length, 1);
      expect(state.items.first.id, 'ann-1');
      expect(state.items.first.titleEn, 'System Update');
    });

    test('updates search query and triggers reload', () async {
      await _settle(container);

      final controller = container.read(announcementListControllerProvider.notifier);
      controller.setSearchQuery('Update');
      controller.submitSearch();
      await _settle(container);

      expect(mockRepository.lastFilters?.query, 'Update');
      expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
    });

    test('updates status filter and triggers reload', () async {
      await _settle(container);

      final controller = container.read(announcementListControllerProvider.notifier);
      controller.setStatusFilter(AnnouncementStatus.scheduled);
      await _settle(container);

      expect(mockRepository.lastFilters?.status, AnnouncementStatus.scheduled);
      expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
    });

    test('updates audience filter and triggers reload', () async {
      await _settle(container);

      final controller = container.read(announcementListControllerProvider.notifier);
      controller.setAudienceFilter(AudienceType.vendors);
      await _settle(container);

      expect(mockRepository.lastFilters?.audienceType, AudienceType.vendors);
      expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
    });

    test('creates announcement and refreshes list', () async {
      await _settle(container);

      final controller = container.read(announcementListControllerProvider.notifier);
      final dto = CreateAnnouncementDto(
        titleEn: 'Souk Open',
        titleAr: 'السوق مفتوح',
        bodyEn: 'Souk trading is now open.',
        bodyAr: 'تداول السوق مفتوح الآن.',
        audience: const {'userType': 'ALL'},
        channels: const {'inApp': true},
      );

      final success = await controller.createAnnouncement(dto);
      await _settle(container);

      expect(success, true);
      expect(mockRepository.createdDto?.titleEn, 'Souk Open');
      expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
    });

    test('handles failure when creating announcement', () async {
      mockRepository.shouldFailCreate = true;
      await _settle(container);

      final controller = container.read(announcementListControllerProvider.notifier);
      final dto = CreateAnnouncementDto(
        titleEn: 'Failed Announcement',
        titleAr: 'إعلان فاشل',
        bodyEn: 'Failed body',
        bodyAr: 'نص فاشل',
        audience: const {'userType': 'ALL'},
        channels: const {'inApp': true},
      );

      final success = await controller.createAnnouncement(dto);

      expect(success, false);
      final state = container.read(announcementListControllerProvider);
      expect(state.errorMessage, contains('Failed to create announcement'));
    });

    test('cancels announcement and refreshes list', () async {
      await _settle(container);

      final controller = container.read(announcementListControllerProvider.notifier);
      final success = await controller.cancelAnnouncement('ann-1');
      await _settle(container);

      expect(success, true);
      expect(mockRepository.cancelledId, 'ann-1');
      expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
    });

    test('handles failure when cancelling announcement', () async {
      mockRepository.shouldFailCancel = true;
      await _settle(container);

      final controller = container.read(announcementListControllerProvider.notifier);
      final success = await controller.cancelAnnouncement('ann-1');

      expect(success, false);
      final state = container.read(announcementListControllerProvider);
      expect(state.errorMessage, contains('Failed to cancel announcement'));
    });
  });
}
