library;

/// Was `_VendorDetailScreenState._formatDate` (TR-S2-10).
String vendorFormatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
