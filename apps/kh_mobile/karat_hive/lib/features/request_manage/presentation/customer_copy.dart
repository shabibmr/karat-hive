import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

String customerFailureMessage(Failure failure, KhStrings s, String fallbackKey) {
  final msg = failure.message?.trim();
  if (msg != null && msg.isNotEmpty) return msg;
  return s.s(fallbackKey);
}

String requestTypeLabel(KhStrings s, RequestType type) =>
    s.s('cus.requestType.${type.wire}');

String requestStateLabel(KhStrings s, RequestState state) =>
    s.s('cus.state.${state.wire}');

KhStatusTone requestStateTone(RequestState state) => switch (state) {
      RequestState.published || RequestState.offersReceived => KhStatusTone.accent,
      RequestState.accepted => KhStatusTone.success,
      RequestState.expired ||
      RequestState.cancelled ||
      RequestState.removed =>
        KhStatusTone.danger,
      RequestState.closed => KhStatusTone.neutral,
      RequestState.draft => KhStatusTone.warning,
      RequestState.unknown => KhStatusTone.neutral,
    };

num? parseMoney(String? raw) => raw == null ? null : num.tryParse(raw);
