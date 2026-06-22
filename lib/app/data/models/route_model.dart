import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/database.dart';

class RouteModel extends Database {
  static const collectionName = 'routes';

  String? id;
  String? name;
  List<String> stopIds;
  String? direction;
  bool? active;

  RouteModel({
    this.id,
    this.name,
    this.stopIds = const [],
    this.direction,
    this.active,
  }) : super(collectionReference: firestore.collection(collectionName));

  RouteModel.fromSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        stopIds = const [],
        super(collectionReference: firestore.collection(collectionName)) {
    final json = doc.data() as Map<String, dynamic>?;
    name = json?['name'];
    direction = json?['direction'];
    active = json?['active'];
    stopIds = List<String>.from(json?['stopIds'] ?? []);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'stopIds': stopIds,
        'direction': direction,
        'active': active,
      };

  static Stream<List<RouteModel>> streamAll() {
    return firestore
        .collection(collectionName)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(RouteModel.fromSnapshot).toList());
  }

  static Future<RouteModel?> getById(String id) async {
    final doc = await firestore.collection(collectionName).doc(id).get();
    if (!doc.exists) return null;
    return RouteModel.fromSnapshot(doc);
  }
}
