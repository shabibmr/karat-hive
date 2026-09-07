import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_queue_item.freezed.dart';
part 'verification_queue_item.g.dart';

/// Summary row from `GET /v1/admin/verification-queue`.
@freezed
class VerificationQueueItem with _$VerificationQueueItem {
  const factory VerificationQueueItem({
    required String id,
    required String legalBusinessName,
    required String tradeLicenceNumber,
    @Default(0) double oldestWaitingHours,
    String? tradingName,
    DateTime? submittedAt,
  }) = _VerificationQueueItem;

  factory VerificationQueueItem.fromJson(Map<String, dynamic> json) =>
      _$VerificationQueueItemFromJson(json);
}
