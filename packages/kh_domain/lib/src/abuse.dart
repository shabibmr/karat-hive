/// Inventory `AbuseEntityType` — REQUEST | OFFER | CONNECTION | REVIEW.
/// `VENDOR` is not a v1 marketplace entity (`SAM-GAP-4`); unknown until the API adds it.
enum AbuseEntityType {
  request,
  offer,
  connection,
  review,
  unknown;

  static AbuseEntityType parse(String? raw) => switch (raw) {
        'REQUEST' => request,
        'OFFER' => offer,
        'CONNECTION' => connection,
        'REVIEW' => review,
        _ => unknown,
      };

  String get wire => switch (this) {
        request => 'REQUEST',
        offer => 'OFFER',
        connection => 'CONNECTION',
        review => 'REVIEW',
        unknown => 'UNKNOWN',
      };
}

enum AbuseReportState {
  open,
  unknown;

  static AbuseReportState parse(String? raw) => switch (raw) {
        'OPEN' => open,
        _ => unknown,
      };
}

class AbuseReport {
  const AbuseReport({
    required this.id,
    required this.state,
    required this.acknowledged,
  });

  final String id;
  final AbuseReportState state;
  final bool acknowledged;

  static AbuseReport fromJson(Map<String, dynamic> j) => AbuseReport(
        id: j['id'] as String,
        state: AbuseReportState.parse(j['state'] as String?),
        acknowledged: j['acknowledged'] as bool? ?? false,
      );
}
