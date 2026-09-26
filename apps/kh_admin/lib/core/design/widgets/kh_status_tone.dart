/// Tone for [KhStatusChip]. Feature code maps Request/Offer/Connection/Vendor
/// states onto these values.
///
/// Owned by `kh_admin` rather than imported from `kh_design_system`: the Admin
/// Portal keeps its own theme, separate from the mobile "1a Classic" system
/// (`apps/kh_mobile/karat_hive/docs/UI-Design-Context.md`).
enum KhStatusTone {
  neutral,
  success,
  warning,
  danger,
  info,
  accent;

  /// Aliases for the admin's original tone names.
  static const KhStatusTone pending = warning;
  static const KhStatusTone error = danger;
  static const KhStatusTone moderation = info;
}
