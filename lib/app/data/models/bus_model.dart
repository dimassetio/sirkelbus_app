import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/database.dart';

class BusModel extends Database {
  static const collectionName = 'buses';

  String? id;
  String? name;
  String? plateNumber;
  int? capacity;

  BusModel({
    this.id,
    this.name,
    this.plateNumber,
    this.capacity,
  }) : super(collectionReference: firestore.collection(collectionName));

  BusModel.fromSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        super(collectionReference: firestore.collection(collectionName)) {
    final json = doc.data() as Map<String, dynamic>?;
    name = json?['name'];
    plateNumber = json?['plateNumber'];
    capacity = (json?['capacity'] as num?)?.toInt();
  }

  String get displayLabel =>
      [name, plateNumber].where((p) => p != null && p.isNotEmpty).join(' - ');

  static Future<List<BusModel>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snaps = await Future.wait(
      ids.map((id) => firestore.collection(collectionName).doc(id).get()),
    );
    return snaps.where((s) => s.exists).map(BusModel.fromSnapshot).toList();
  }

  static Future<BusModel?> getById(String id) async {
    final doc = await firestore.collection(collectionName).doc(id).get();
    if (!doc.exists) return null;
    return BusModel.fromSnapshot(doc);
  }
}
