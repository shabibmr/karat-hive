/// Small display helpers shared by the announcement widgets.
/// Were `_AnnouncementsScreenState._shortId` / `_formatDateTime` (TR-S2-08).
library;

String announcementShortId(String id, [int maxLen = 8]) =>
    id.length > maxLen ? id.substring(0, maxLen) : id;

String announcementFormatDateTime(DateTime? dt, [int maxLen = 16]) {
  if (dt == null) return '-';
  final str = dt.toLocal().toString();
  return str.length >= maxLen ? str.substring(0, maxLen) : str;
}
