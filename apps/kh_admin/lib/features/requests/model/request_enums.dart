import 'package:json_annotation/json_annotation.dart';

/// Type of request submitted by customer.
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

  String get label {
    switch (this) {
      case RequestType.findOrnament:
        return 'Find Ornament';
      case RequestType.sellOldGold:
        return 'Sell Old Gold';
      case RequestType.goldCoin:
        return 'Gold Coins';
      case RequestType.goldBullion:
        return 'Gold Bullion';
    }
  }

  static RequestType? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final t in RequestType.values) {
      if (t.apiValue == value || t.name.toLowerCase() == value.toLowerCase()) {
        return t;
      }
    }
    return null;
  }
}

/// Market direction: BUY or SELL.
@JsonEnum(alwaysCreate: true)
enum Direction {
  @JsonValue('BUY')
  buy,
  @JsonValue('SELL')
  sell;

  String get apiValue {
    switch (this) {
      case Direction.buy:
        return 'BUY';
      case Direction.sell:
        return 'SELL';
    }
  }

  String get label {
    switch (this) {
      case Direction.buy:
        return 'BUY';
      case Direction.sell:
        return 'SELL';
    }
  }

  static Direction? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final d in Direction.values) {
      if (d.apiValue == value || d.name.toLowerCase() == value.toLowerCase()) {
        return d;
      }
    }
    return null;
  }
}

/// Lifecycle state for customer requests (`RequestState` in Prisma).
@JsonEnum(alwaysCreate: true)
enum RequestState {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('PUBLISHED')
  published,
  @JsonValue('OFFERS_RECEIVED')
  offersReceived,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('CLOSED')
  closed,
  @JsonValue('EXPIRED')
  expired,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('REMOVED')
  removed;

  String get apiValue {
    switch (this) {
      case RequestState.draft:
        return 'DRAFT';
      case RequestState.published:
        return 'PUBLISHED';
      case RequestState.offersReceived:
        return 'OFFERS_RECEIVED';
      case RequestState.accepted:
        return 'ACCEPTED';
      case RequestState.closed:
        return 'CLOSED';
      case RequestState.expired:
        return 'EXPIRED';
      case RequestState.cancelled:
        return 'CANCELLED';
      case RequestState.removed:
        return 'REMOVED';
    }
  }

  String get label {
    switch (this) {
      case RequestState.draft:
        return 'DRAFT';
      case RequestState.published:
        return 'PUBLISHED';
      case RequestState.offersReceived:
        return 'OFFERS RECEIVED';
      case RequestState.accepted:
        return 'ACCEPTED';
      case RequestState.closed:
        return 'CLOSED';
      case RequestState.expired:
        return 'EXPIRED';
      case RequestState.cancelled:
        return 'CANCELLED';
      case RequestState.removed:
        return 'REMOVED';
    }
  }

  static RequestState? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final s in RequestState.values) {
      if (s.apiValue == value || s.name.toLowerCase() == value.toLowerCase()) {
        return s;
      }
    }
    return null;
  }
}

/// Offer lifecycle state (`OfferState` in Prisma).
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

  String get label {
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
        return 'WITHDRAWN (SYSTEM)';
    }
  }

  static OfferState? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final o in OfferState.values) {
      if (o.apiValue == value || o.name.toLowerCase() == value.toLowerCase()) {
        return o;
      }
    }
    return null;
  }
}
