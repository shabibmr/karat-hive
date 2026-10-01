import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  /// Lazily resolves so unit tests can construct the service without
  /// initializing Firebase; first real use still needs a Firebase app.
  FirebaseFirestore get instance => _override ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      instance.collection(collectionPath);

  DocumentReference<Map<String, dynamic>> document(String documentPath) =>
      instance.doc(documentPath);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) =>
      instance.doc(path).get();

  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = true,
  }) =>
      instance.doc(path).set(data, SetOptions(merge: merge));

  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream(String path) =>
      instance.doc(path).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(
    String collectionPath, {
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) {
    final collectionRef = instance.collection(collectionPath);
    final query = queryBuilder != null ? queryBuilder(collectionRef) : collectionRef;
    return query.snapshots();
  }
}

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());
