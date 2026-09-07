import 'announcement_item.dart';

/// Cursor-paginated page of announcements.
class AnnouncementPage {
  const AnnouncementPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<AnnouncementItem> items;
  final String? nextCursor;
  final bool hasMore;
}
