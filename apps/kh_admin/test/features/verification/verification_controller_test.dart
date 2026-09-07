import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/verification/controller/verification_controller.dart';
import 'package:kh_admin/features/verification/model/document_url_response.dart';
import 'package:kh_admin/features/verification/model/verification_decision_dto.dart';
import 'package:kh_admin/features/verification/model/verification_queue_item.dart';
import 'package:kh_admin/features/verification/model/vendor_verification_detail.dart';
import 'package:kh_admin/features/verification/repository/verification_repository.dart';

class _MockVerificationRepository extends VerificationRepository {
  _MockVerificationRepository() : super(ApiClient());

  List<VerificationQueueItem> queue = [
    const VerificationQueueItem(
      id: 'vendor-1',
      legalBusinessName: 'Al Noor Jewellery LLC',
      tradeLicenceNumber: 'CN-1092834',
      oldestWaitingHours: 36,
      tradingName: 'Al Noor',
    ),
    const VerificationQueueItem(
      id: 'vendor-2',
      legalBusinessName: 'Gold Souk Trading',
      tradeLicenceNumber: 'CN-5550001',
      oldestWaitingHours: 12,
    ),
  ];

  VendorVerificationDetail detail = VendorVerificationDetail(
    id: 'vendor-1',
    legalBusinessName: 'Al Noor Jewellery LLC',
    tradeLicenceNumber: 'CN-1092834',
    licenceExpiryDate: DateTime.utc(2027, 6, 30),
    businessAddress: 'Deira, Dubai',
    contactPersonName: 'Ahmed Hassan',
    businessEmail: 'ahmed@alnoor.ae',
    mobileNumber: '+97145550101',
    regions: const ['Dubai (Deira)'],
    documents: [
      VendorDocumentDetail(
        id: 'doc-1',
        documentType: 'TRADE_LICENCE',
        uploadedAt: DateTime.utc(2026, 1, 1),
        fileName: 'Trade_Licence_Dubai.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 2400000,
      ),
    ],
  );

  bool shouldFail = false;
  String? lastVerifiedId;
  String? lastRejectedId;
  String? lastRequestInfoId;
  String? lastRationale;
  String? lastMessage;

  @override
  Future<List<VerificationQueueItem>> fetchQueue() async {
    if (shouldFail) throw Exception('Queue fetch failed');
    return queue;
  }

  @override
  Future<VendorVerificationDetail> fetchVendorDetail(String vendorId) async {
    if (shouldFail) throw Exception('Detail fetch failed');
    return detail.copyWith(id: vendorId);
  }

  @override
  Future<DocumentUrlResponse> fetchDocumentUrl({
    required String vendorId,
    required String documentId,
  }) async {
    return DocumentUrlResponse(
      url: 'https://example.com/$documentId',
      expiresAt: DateTime.utc(2026, 9, 7, 12),
    );
  }

  @override
  Future<void> verifyVendor(String vendorId, VerifyDecisionDto dto) async {
    if (shouldFail) throw Exception('Verify failed');
    lastVerifiedId = vendorId;
    lastRationale = dto.rationale;
    queue = queue.where((item) => item.id != vendorId).toList();
  }

  @override
  Future<void> rejectVendor(String vendorId, RejectDecisionDto dto) async {
    if (shouldFail) throw Exception('Reject failed');
    lastRejectedId = vendorId;
    lastRationale = dto.rationale;
    queue = queue.where((item) => item.id != vendorId).toList();
  }

  @override
  Future<void> requestInfo(String vendorId, RequestInfoDto dto) async {
    if (shouldFail) throw Exception('Request info failed');
    lastRequestInfoId = vendorId;
    lastMessage = dto.message;
  }
}

void main() {
  late ProviderContainer container;
  late _MockVerificationRepository mockRepository;

  setUp(() {
    mockRepository = _MockVerificationRepository();
    container = ProviderContainer(
      overrides: [
        verificationRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('VerificationQueueController loads queue oldest-first', () async {
    final state = await container.read(verificationQueueControllerProvider.future);

    expect(state.length, 2);
    expect(state.first.legalBusinessName, 'Al Noor Jewellery LLC');
    expect(state.first.oldestWaitingHours, 36);
  });

  test('VerificationQueueController verifies vendor and reloads queue', () async {
    await container.read(verificationQueueControllerProvider.future);

    final controller =
        container.read(verificationQueueControllerProvider.notifier);
    await controller.verifyVendor('vendor-1', 'Documents match DED records.');

    expect(mockRepository.lastVerifiedId, 'vendor-1');
    expect(mockRepository.lastRationale, 'Documents match DED records.');

    final updated = container.read(verificationQueueControllerProvider).value!;
    expect(updated.length, 1);
    expect(updated.first.id, 'vendor-2');
  });

  test('VerificationDetailController loads vendor detail', () async {
    final detail = await container.read(
      verificationDetailControllerProvider('vendor-1').future,
    );

    expect(detail.legalBusinessName, 'Al Noor Jewellery LLC');
    expect(detail.documents, isNotEmpty);
    expect(detail.documents.first.fileName, 'Trade_Licence_Dubai.pdf');
  });

  test('VerificationQueueController request-info keeps vendor in queue', () async {
    await container.read(verificationQueueControllerProvider.future);

    final controller =
        container.read(verificationQueueControllerProvider.notifier);
    await controller.requestInfo('vendor-1', 'Please upload clearer Emirates ID scan.');

    expect(mockRepository.lastRequestInfoId, 'vendor-1');
    expect(mockRepository.lastMessage, 'Please upload clearer Emirates ID scan.');

    final updated = container.read(verificationQueueControllerProvider).value!;
    expect(updated.length, 2);
  });
}
