import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/requests/model/request_enums.dart';

/// Label/value row for the request detail cards.
///
/// Extracted verbatim from `RequestDetailScreen._buildDetailRow` (TR-S2-06 /
/// ADM-SMP-11). Keeps the request screen's exact metrics rather than the
/// `KhDetailRow` defaults so the split is a no-op visually.
class RequestDetailRow extends StatelessWidget {
  const RequestDetailRow(
    this.label,
    this.value, {
    super.key,
    this.highlightGold = false,
  });

  final String label;
  final String value;
  final bool highlightGold;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: kh.spacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.0,
            child: Text(
              label,
              style: kh.typography.caption.copyWith(
                color: kh.colors.textMuted,
                fontSize: 12.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: kh.typography.bodySmall.copyWith(
                color:
                    highlightGold ? kh.colors.goldPrimary : kh.colors.textPrimary,
                fontWeight: highlightGold ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status-chip tone for a [RequestState]. Was `_stateTone` on the screen.
KhStatusTone requestStateTone(RequestState state) {
  switch (state) {
    case RequestState.draft:
      return KhStatusTone.neutral;
    case RequestState.published:
      return KhStatusTone.moderation;
    case RequestState.offersReceived:
      return KhStatusTone.pending;
    case RequestState.accepted:
      return KhStatusTone.success;
    case RequestState.closed:
    case RequestState.expired:
      return KhStatusTone.neutral;
    case RequestState.cancelled:
    case RequestState.removed:
      return KhStatusTone.error;
  }
}

/// Status-chip tone for an [OfferState]. Was `_offerStateTone` on the screen.
KhStatusTone offerStateTone(OfferState state) {
  switch (state) {
    case OfferState.accepted:
      return KhStatusTone.success;
    case OfferState.pending:
      return KhStatusTone.pending;
    case OfferState.rejected:
    case OfferState.expired:
    case OfferState.withdrawn:
    case OfferState.withdrawnBySystem:
      return KhStatusTone.error;
  }
}
