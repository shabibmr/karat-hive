import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/moderation/model/moderation_review_item.dart';

/// Cursor-paginated page of moderation review entries (ADM-S16).
typedef ModerationPage = Paginated<ModerationReviewItem>;
