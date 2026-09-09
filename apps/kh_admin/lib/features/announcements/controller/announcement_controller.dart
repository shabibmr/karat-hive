import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/model/create_announcement_dto.dart';
import 'package:kh_admin/features/announcements/repository/announcement_repository.dart';

typedef AnnouncementListState
    = CursorListState<AnnouncementItem, AnnouncementFilters>;

class AnnouncementListController
    extends CursorPaginatedNotifier<AnnouncementItem, AnnouncementFilters> {
  @override
  AnnouncementFilters get initialFilters => const AnnouncementFilters();

  @override
  Object? Function(AnnouncementItem item)? get itemKey => (item) => item.id;

  @override
  int get pageSize => 50;

  @override
  Future<Paginated<AnnouncementItem>> fetchPage({
    required AnnouncementFilters filters,
    String? cursor,
    int limit = 50,
  }) {
    return ref.read(announcementRepositoryProvider).fetchAnnouncements(
          filters: filters,
          cursor: cursor,
          limit: limit,
        );
  }

  void setSearchQuery(String query) {
    applyFilters(state.filters.copyWith(query: query));
  }

  void submitSearch() => refresh();

  void setStatusFilter(AnnouncementStatus? status) {
    applyFilters(
      state.filters.copyWith(
        status: status,
        clearStatus: status == null,
      ),
    );
  }

  void setAudienceFilter(AudienceType? audienceType) {
    applyFilters(
      state.filters.copyWith(
        audienceType: audienceType,
        clearAudienceType: audienceType == null,
      ),
    );
  }

  Future<bool> createAnnouncement(CreateAnnouncementDto dto) async {
    try {
      await ref.read(announcementRepositoryProvider).createAnnouncement(dto);
      await refresh();
      return true;
    } on Object catch (e) {
      state = CursorListError<AnnouncementItem, AnnouncementFilters>(
        filters: state.filters,
        errorMessage: 'Failed to create announcement: $e',
        rawError: e,
        items: state.items,
        page: state.page,
        nextCursor: state.nextCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
      return false;
    }
  }

  Future<bool> cancelAnnouncement(String id) async {
    try {
      await ref.read(announcementRepositoryProvider).cancelAnnouncement(id);
      await refresh();
      return true;
    } on Object catch (e) {
      state = CursorListError<AnnouncementItem, AnnouncementFilters>(
        filters: state.filters,
        errorMessage: 'Failed to cancel announcement: $e',
        rawError: e,
        items: state.items,
        page: state.page,
        nextCursor: state.nextCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
      return false;
    }
  }
}

final announcementListControllerProvider =
    NotifierProvider<AnnouncementListController, AnnouncementListState>(
  AnnouncementListController.new,
);
