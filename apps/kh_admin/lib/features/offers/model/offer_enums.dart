import 'package:json_annotation/json_annotation.dart';

import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';

part 'offer_enums.g.dart';

/// State of an offer submitted by a vendor (`OfferState` in Prisma).
@JsonEnum(alwaysCreate: true)
enum OfferState {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('EXPIRED')
  expired,
  @JsonValue('WITHDRAWN')
  withdrawn,
  @JsonValue('WITHDRAWN_BY_SYSTEM')
  withdrawnBySystem;

  String get apiValue {
    switch (this) {
      case OfferState.pending:
        return 'PENDING';
      case OfferState.accepted:
        return 'ACCEPTED';
      case OfferState.rejected:
        return 'REJECTED';
      case OfferState.expired:
        return 'EXPIRED';
      case OfferState.withdrawn:
        return 'WITHDRAWN';
      case OfferState.withdrawnBySystem:
        return 'WITHDRAWN_BY_SYSTEM';
    }
  }

  static OfferState? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final state in OfferState.values) {
      if (state.apiValue == value) return state;
    }
    return null;
  }

  String get displayName {
    switch (this) {
      case OfferState.pending:
        return 'Pending';
      case OfferState.accepted:
        return 'Accepted';
      case OfferState.rejected:
        return 'Rejected';
      case OfferState.expired:
        return 'Expired';
      case OfferState.withdrawn:
        return 'Withdrawn';
      case OfferState.withdrawnBySystem:
        return 'System Withdrawn';
    }
  }

  KhStatusTone get statusTone {
    switch (this) {
      case OfferState.accepted:
        return KhStatusTone.success;
      case OfferState.pending:
        return KhStatusTone.pending;
      case OfferState.rejected:
        return KhStatusTone.error;
      case OfferState.expired:
        return KhStatusTone.neutral;
      case OfferState.withdrawn:
        return KhStatusTone.neutral;
      case OfferState.withdrawnBySystem:
        return KhStatusTone.error;
    }
  }
}

/// Request type for request filtering (`RequestType` in Prisma).
@JsonEnum(alwaysCreate: true)
enum RequestType {
  @JsonValue('FIND_ORNAMENT')
  findOrnament,
  @JsonValue('SELL_OLD_GOLD')
  sellOldGold,
  @JsonValue('GOLD_COIN')
  goldCoin,
  @JsonValue('GOLD_BULLION')
  goldBullion;

  String get apiValue {
    switch (this) {
      case RequestType.findOrnament:
        return 'FIND_ORNAMENT';
      case RequestType.sellOldGold:
        return 'SELL_OLD_GOLD';
      case RequestType.goldCoin:
        return 'GOLD_COIN';
      case RequestType.goldBullion:
        return 'GOLD_BULLION';
    }
  }

  static RequestType? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final type in RequestType.values) {
      if (type.apiValue == value) return type;
    }
    return null;
  }

  String get displayName {
    switch (this) {
      case RequestType.findOrnament:
        return 'Find Ornament';
      case RequestType.sellOldGold:
        return 'Sell Old Gold';
      case RequestType.goldCoin:
        return 'Gold Coin';
      case RequestType.goldBullion:
        return 'Gold Bullion';
    }
  }
}
