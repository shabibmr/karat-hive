import 'announcement_enums.dart';

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
    };
  }
}
