import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/database.dart';

class DriverModel extends Database {
  static const collectionName = 'drivers';

  String? id;
  String? userId;
  String? assignedBusId;
  String? status;

  DriverModel({
    this.id,
    this.userId,
    this.assignedBusId,
    this.status,
  }) : super(collectionReference: firestore.collection(collectionName));

  DriverModel.fromSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        super(collectionReference: firestore.collection(collectionName)) {
    final json = doc.data() as Map<String, dynamic>?;
    userId = json?['userId'];
    assignedBusId = json?['assignedBusId'];
    status = json?['status'];
  }

  // schedules/trips reference drivers by this doc id, not the Firebase Auth
  // uid — resolve it once so driver-owned queries can filter correctly.
  static Future<String?> docIdForUser(String uid) async {
    final snap = await firestore
        .collection(collectionName)
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : snap.docs.first.id;
  }
}
