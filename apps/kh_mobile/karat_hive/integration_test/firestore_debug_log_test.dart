import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:karat_hive/core/firebase/firestore_debug_logger.dart';
import 'package:karat_hive/core/firebase/firestore_service.dart';
import 'package:karat_hive/firebase_options.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_media/kh_media.dart';
import 'package:mocktail/mocktail.dart';

/// Runs the real upload pipeline against a stubbed backend whose storage PUT is
/// rejected, then reads `debug_logs` back from the live Firestore project.
///
///   flutter test integration_test/firestore_debug_log_test.dart -d DEVICE
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/firestore_debug_log_test.dart -d chrome
///
/// Needs `debug_logs` writes (and reads, for this check) allowed by the
/// Firestore rules. Uses a unique scope per run and deletes what it wrote.
class _MockKhApi extends Mock implements KhApi {}

/// Answers every request with a fixed status/body — no network.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.throwError});

  static const _status = 403;
  static const _body = 'AccessDenied';

  final DioExceptionType? throwError;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (throwError != null) {
      throw DioException(
        requestOptions: options,
        type: throwError!,
        message: 'simulated ${throwError!.name}',
      );
    }
    return ResponseBody.fromString(_body, _status);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirestoreDebugLogger logger;
  late FirebaseFirestore db;
  late String scope;
  late _MockKhApi api;

  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    db = FirebaseFirestore.instance;
    logger = FirestoreDebugLogger(FirestoreService(firestore: db));
  });

  setUp(() {
    scope = 'it-upload-${DateTime.now().microsecondsSinceEpoch}';
    api = _MockKhApi();
    when(() => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        )).thenAnswer((_) async => const Ok(UploadIntent(
          key: 'req/test-key.png',
          uploadUrl: 'https://bucket.example.com/req/test-key.png?X-Sig=secret',
          requiredHeaders: {'x-amz-meta-purpose': 'REQUEST_IMAGE'},
          maxBytes: 5 * 1024 * 1024,
        )));
  });

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchLogs() async {
    for (var i = 0; i < 20; i++) {
      final snap = await db.collection('debug_logs').where('scope', isEqualTo: scope).get();
      if (snap.docs.length >= 3) return snap.docs;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return (await db.collection('debug_logs').where('scope', isEqualTo: scope).get()).docs;
  }

  Future<void> cleanup(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    for (final d in docs) {
      await d.reference.delete();
    }
  }

  testWidgets('rejected PUT (403) is written to Firestore with status + body', (_) async {
    final uploader = MediaUploader(
      api,
      putClient: Dio()
        ..httpClientAdapter = _StubAdapter()
        ..options.validateStatus = (_) => true,
      onDebug: logger.sinkFor(scope),
    );

    final res = await uploader.uploadBytes(
      Uint8List.fromList(List.filled(2048, 1)),
      purpose: MediaUploadPurpose.requestImage,
      contentType: 'image/png',
    );
    expect(res.failureOrNull, isNotNull, reason: 'upload should fail');

    final docs = await fetchLogs();
    addTearDown(() => cleanup(docs));
    final byEvent = {for (final d in docs) d['event'] as String: d.data()};

    expect(byEvent.keys, containsAll(['upload.start', 'upload.put', 'upload.putRejected']));
    expect(byEvent['upload.putRejected']!['data']['status'], 403);
    expect(byEvent['upload.putRejected']!['data']['body'], 'AccessDenied');
    expect(byEvent['upload.put']!['data']['contentType'], 'image/png');
    expect(byEvent['upload.put']!['data']['host'], 'bucket.example.com');
    // Signed query string must never be persisted.
    expect(docs.map((d) => '${d.data()}').join(), isNot(contains('secret')));
    expect(byEvent['upload.start']!['ts'], isA<Timestamp>());
  });

  testWidgets('transport error (CORS-like) is written to Firestore', (_) async {
    final uploader = MediaUploader(
      api,
      putClient: Dio()..httpClientAdapter = _StubAdapter(throwError: DioExceptionType.connectionError),
      onDebug: logger.sinkFor(scope),
    );

    await uploader.uploadBytes(
      Uint8List.fromList(List.filled(2048, 1)),
      purpose: MediaUploadPurpose.requestImage,
      contentType: 'image/png',
    );

    final docs = await fetchLogs();
    addTearDown(() => cleanup(docs));
    final ex = docs.firstWhere((d) => d['event'] == 'upload.putDioException').data();
    expect(ex['data']['type'], 'connectionError');
    expect(ex['data']['status'], isNull);
  });
}
