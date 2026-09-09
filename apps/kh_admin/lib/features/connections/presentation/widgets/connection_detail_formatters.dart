library;

/// Was `_ConnectionDetailScreenState._formatPrice` (TR-S2-14).
String connectionFormatPrice(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
  return 'AED $whole.${parts[1]}';
}

/// Was `_ConnectionDetailScreenState._formatDate` (TR-S2-14).
String connectionFormatDate(DateTime? dt) {
  if (dt == null) return '—';
  final utc = dt.toUtc();
  final gst = utc.add(const Duration(hours: 4));
  final year = gst.year.toString().padLeft(4, '0');
  final month = gst.month.toString().padLeft(2, '0');
  final day = gst.day.toString().padLeft(2, '0');
  final hour = gst.hour.toString().padLeft(2, '0');
  final minute = gst.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute GST';
}
