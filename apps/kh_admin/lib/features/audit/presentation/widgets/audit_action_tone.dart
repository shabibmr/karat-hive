import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';

/// Was `_AuditScreenState._toneForAction` (TR-S2-13).
KhStatusTone auditToneForAction(String action) {
  final act = action.toUpperCase();
  if (act.contains('SUSPEND') ||
      act.contains('REJECT') ||
      act.contains('CLOSE') ||
      act.contains('REVOKE') ||
      act.contains('CANCEL') ||
      act.contains('ERASURE')) {
    return KhStatusTone.error;
  }
  if (act.contains('VERIF') ||
      act.contains('REACTIVATE') ||
      act.contains('APPROVE') ||
      act.contains('RESOLVE') ||
      act.contains('CREATED')) {
    return KhStatusTone.success;
  }
  if (act.contains('INFO') || act.contains('REDACT')) {
    return KhStatusTone.moderation;
  }
  return KhStatusTone.neutral;
}
