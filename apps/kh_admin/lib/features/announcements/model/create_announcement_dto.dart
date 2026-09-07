/// DTO for composing and scheduling a new platform announcement (ADM-S18).
class CreateAnnouncementDto {
  const CreateAnnouncementDto({
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.audience,
    required this.channels,
    this.critical = false,
    this.scheduledFor,
  });

  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final Map<String, dynamic> audience;
  final Map<String, dynamic> channels;
  final bool critical;
  final DateTime? scheduledFor;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'titleEn': titleEn,
      'titleAr': titleAr,
      'bodyEn': bodyEn,
      'bodyAr': bodyAr,
      'audience': audience,
      'channels': channels,
      'critical': critical,
      if (scheduledFor != null) 'scheduledFor': scheduledFor!.toUtc().toIso8601String(),
    };
  }
}
