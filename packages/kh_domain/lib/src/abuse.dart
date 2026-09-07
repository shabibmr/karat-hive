/// Inventory `AbuseEntityType` plus live `VENDOR` / `CUSTOMER` (`SAM-GAP-4` built).
enum AbuseEntityType {
  request,
  offer,
  connection,
  review,
  vendor,
  customer,
  unknown;

  static AbuseEntityType parse(String? raw) => switch (raw) {
        'REQUEST' => request,
        'OFFER' => offer,
        'CONNECTION' => connection,
        'REVIEW' => review,
        'VENDOR' => vendor,
        'CUSTOMER' => customer,
        _ => unknown,
      };

  String get wire => switch (this) {
        request => 'REQUEST',
        offer => 'OFFER',
        connection => 'CONNECTION',
        review => 'REVIEW',
        vendor => 'VENDOR',
        customer => 'CUSTOMER',
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
