/// Export file format for `POST /v1/admin/exports`.
enum ExportFormat {
  csv('CSV'),
  xlsx('XLSX'),
  png('PNG');

  const ExportFormat(this.apiValue);

  final String apiValue;
}

/// Async export job lifecycle (`QUEUED` | `RUNNING` | `READY` | `FAILED`).
enum ExportJobStatus {
  queued,
  running,
  ready,
  failed;

  bool get isTerminal => this == ready || this == failed;

  static ExportJobStatus fromApi(String? raw) {
    switch (raw?.trim().toUpperCase()) {
      case 'RUNNING':
        return ExportJobStatus.running;
      case 'READY':
        return ExportJobStatus.ready;
      case 'FAILED':
        return ExportJobStatus.failed;
      case 'QUEUED':
      default:
        return ExportJobStatus.queued;
    }
  }
}

/// `GET /v1/admin/exports/{id}` payload.
class ExportJob {
  const ExportJob({
    required this.id,
    required this.status,
    this.downloadUrl,
    this.watermark,
    this.completedAt,
  });

  final String id;
  final ExportJobStatus status;
  final String? downloadUrl;
  final Map<String, dynamic>? watermark;
  final DateTime? completedAt;

  factory ExportJob.fromJson(Map<String, dynamic> json) {
    final watermarkRaw = json['watermark'];
    return ExportJob(
      id: json['id']?.toString() ?? '',
      status: ExportJobStatus.fromApi(
        json['status']?.toString() ?? json['state']?.toString(),
      ),
      downloadUrl: json['downloadUrl']?.toString() ?? json['download_url']?.toString(),
      watermark: watermarkRaw is Map
          ? Map<String, dynamic>.from(watermarkRaw)
          : null,
      completedAt: _parseDate(json['completedAt'] ?? json['completed_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
