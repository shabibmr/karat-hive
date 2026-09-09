/// Shared display formatters for the offer detail widgets.
///
/// Moved verbatim from the `_OfferDetailScreenState._formatPrice` /
/// `_formatDate` statics (TR-S2-07) so each extracted card can call them
/// directly instead of receiving them as constructor callbacks.
library;

/// `AED 1,234.56` style price formatting.
String offerFormatPrice(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
  return 'AED $whole.${parts[1]}';
}

/// `dd/MM/yyyy HH:mm GST` style date formatting; `—` for null.
String offerFormatDate(DateTime? dt) {
  if (dt == null) return '—';
  final year = dt.year.toString().padLeft(4, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final day = dt.day.toString().padLeft(2, '0');
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute GST';
}
