import 'report_name.dart';

/// One plotted value derived from `series` or numeric `rows`.
class ReportChartPoint {
  const ReportChartPoint({required this.label, required this.value});

  final String label;
  final double value;
}

/// `GET /v1/admin/reports/{name}` payload: `{ name, generatedAt, rows, series }`.
class ReportResult {
  const ReportResult({
    required this.name,
    required this.generatedAt,
    this.rows = const [],
    this.series = const [],
  });

  final ReportName name;
  final DateTime generatedAt;
  final List<Map<String, dynamic>> rows;
  final List<Map<String, dynamic>> series;

  bool get isEmpty => rows.isEmpty && series.isEmpty;

  List<String> get columnKeys {
    final keys = <String>[];
    for (final row in rows) {
      for (final key in row.keys) {
        if (!keys.contains(key)) keys.add(key);
      }
    }
    return keys;
  }

  /// Chart series when the API supplies `series`; otherwise numeric fields on `rows`.
  List<ReportChartPoint> get chartPoints {
    if (series.isNotEmpty) {
      return series
          .map(_pointFromMap)
          .whereType<ReportChartPoint>()
          .toList(growable: false);
    }
    return rows
        .map(_pointFromMap)
        .whereType<ReportChartPoint>()
        .toList(growable: false);
  }

  int get numericTotal {
    var total = 0;
    for (final row in rows) {
      final value = _firstNumeric(row);
      if (value != null) total += value.round();
    }
    return total;
  }

  factory ReportResult.fromJson(Map<String, dynamic> json) {
    final generatedRaw = json['generatedAt'] ?? json['generated_at'];
    return ReportResult(
      name: ReportName.fromApi(json['name']?.toString()),
      generatedAt: _parseDate(generatedRaw) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      rows: _objectList(json['rows']),
      series: _objectList(json['series']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static List<Map<String, dynamic>> _objectList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  static ReportChartPoint? _pointFromMap(Map<String, dynamic> map) {
    final numeric = _firstNumeric(map);
    if (numeric == null) return null;
    final label = _firstLabel(map);
    return ReportChartPoint(label: label, value: numeric);
  }

  static double? _firstNumeric(Map<String, dynamic> map) {
    const preferred = ['value', 'count', 'y', 'total'];
    for (final key in preferred) {
      final parsed = _asDouble(map[key]);
      if (parsed != null) return parsed;
    }
    for (final entry in map.entries) {
      final parsed = _asDouble(entry.value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String _firstLabel(Map<String, dynamic> map) {
    const preferred = [
      'label',
      'name',
      'stage',
      'state',
      'rating',
      'category',
      'region',
      'x',
      'date',
    ];
    for (final key in preferred) {
      final value = map[key];
      if (value != null && _asDouble(value) == null) {
        return value.toString();
      }
      if (key == 'rating' && value != null) return value.toString();
    }
    for (final entry in map.entries) {
      if (_asDouble(entry.value) == null) return entry.value.toString();
    }
    return map.values.isEmpty ? '' : map.values.first.toString();
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
