import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  FirebaseFirestore get instance => _firestore;

  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _firestore.collection(collectionPath);

  DocumentReference<Map<String, dynamic>> document(String documentPath) =>
      _firestore.doc(documentPath);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) =>
      _firestore.doc(path).get();

  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = true,
  }) =>
      _firestore.doc(path).set(data, SetOptions(merge: merge));

  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream(String path) =>
      _firestore.doc(path).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(
    String collectionPath, {
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
