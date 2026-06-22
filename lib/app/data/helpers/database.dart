import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class Database {
  final CollectionReference collectionReference;

  Database({required this.collectionReference});

  Future<String?> add(Map<String, dynamic> json) async {
    try {
      json['createdAt'] = DateTime.now();
      final res = await collectionReference.add(json);
      return res.id;
    } on FirebaseException catch (e) {
      Get.snackbar(e.code, e.message ?? '');
      return null;
    }
  }

  Future<bool> set(String id, Map<String, dynamic> json) async {
    try {
      json['createdAt'] = DateTime.now();
      await collectionReference.doc(id).set(json);
      return true;
    } on FirebaseException catch (e) {
      Get.snackbar(e.code, e.message ?? '');
      return false;
    }
  }

  Future<DocumentSnapshot> getID(String id) {
    return collectionReference.doc(id).get();
  }

  Future edit(String id, Map<String, dynamic> json) async {
    try {
      json['updatedAt'] = DateTime.now();
      return await collectionReference.doc(id).update(json);
    } on FirebaseException catch (e) {
      Get.snackbar(e.code, e.message ?? '');
      rethrow;
    }
  }

  Stream<DocumentSnapshot> docSnapshots({required String id}) {
    return collectionReference.doc(id).snapshots();
  }

  Stream<QuerySnapshot> snapshots({String? sortBy, bool descending = false}) {
    final coll = (sortBy == null || sortBy.isEmpty)
        ? collectionReference
        : collectionReference.orderBy(sortBy, descending: descending);
    return coll.snapshots();
  }
}
