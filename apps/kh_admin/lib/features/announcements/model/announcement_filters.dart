import 'package:kh_admin/features/announcements/model/announcement_enums.dart';

/// Filter criteria for querying and filtering announcements.
class AnnouncementFilters {
  const AnnouncementFilters({
    this.status,
    this.audienceType,
    this.query = '',
  });

  final AnnouncementStatus? status;
  final AudienceType? audienceType;
  final String query;

  AnnouncementFilters copyWith({
    AnnouncementStatus? status,
    bool clearStatus = false,
    AudienceType? audienceType,
    bool clearAudienceType = false,
    String? query,
  }) {
    return AnnouncementFilters(
      status: clearStatus ? null : (status ?? this.status),
      audienceType: clearAudienceType ? null : (audienceType ?? this.audienceType),
      query: query ?? this.query,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (status != null) 'status': status!.wireValue,
      if (audienceType != null) 'audienceType': audienceType!.wireValue,
      if (query.trim().isNotEmpty) 'q': query.trim(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementFilters &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          audienceType == other.audienceType &&
          query == other.query;

  @override
  int get hashCode => Object.hash(status, audienceType, query);

  @override
  String toString() =>
      'AnnouncementFilters(status: $status, audienceType: $audienceType, query: $query)';
}
