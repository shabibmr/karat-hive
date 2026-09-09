library;

/// Was `_CustomerDetailScreenState._formatDate` (TR-S2-12).
String customerFormatDate(DateTime? dt) {
  if (dt == null) return '—';
  return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

/// Was `_CustomerDetailScreenState._formatDateTime` (TR-S2-12).
String customerFormatDateTime(DateTime? dt) {
  if (dt == null) return '—';
  final date = customerFormatDate(dt);
  final time =
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}
