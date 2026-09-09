import 'package:kh_admin/features/moderation/model/moderation_review_item.dart';

class ModerationPage {
  const ModerationPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<ModerationReviewItem> items;
  final String? nextCursor;
  final bool hasMore;
}
