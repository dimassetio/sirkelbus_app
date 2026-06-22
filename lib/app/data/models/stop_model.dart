import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/database.dart';

abstract class StopCategory {
  static const normal = 'normal';
  static const departure = 'departure';
  static const school = 'school';
}

class StopModel extends Database {
  static const collectionName = 'stops';

  String? id;
  String? name;
  double? lat;
  double? lng;
  int? order;
  String? category;
  String? addressDetail;
  String? kelurahan;
  String? kecamatan;
  String? city;
  bool? active;

  StopModel({
    this.id,
    this.name,
    this.lat,
    this.lng,
    this.order,
    this.category,
    this.addressDetail,
    this.kelurahan,
    this.kecamatan,
    this.city,
    this.active,
  }) : super(collectionReference: firestore.collection(collectionName));

  StopModel.fromSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        super(collectionReference: firestore.collection(collectionName)) {
    final json = doc.data() as Map<String, dynamic>?;
    name = json?['name'];
    lat = (json?['lat'] as num?)?.toDouble();
    lng = (json?['lng'] as num?)?.toDouble();
    order = (json?['order'] as num?)?.toInt();
    category = json?['category'];
    addressDetail = json?['addressDetail'];
    kelurahan = json?['kelurahan'];
    kecamatan = json?['kecamatan'];
    city = json?['city'];
    active = json?['active'];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lng': lng,
        'order': order,
        'category': category,
        'addressDetail': addressDetail,
        'kelurahan': kelurahan,
        'kecamatan': kecamatan,
        'city': city,
        'active': active,
      };

  String get displayLocation {
    return [kelurahan, kecamatan, city]
        .where((p) => p != null && p.isNotEmpty)
        .join(', ');
  }

  static Stream<List<StopModel>> streamAll() {
    return firestore
        .collection(collectionName)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(StopModel.fromSnapshot).toList());
  }

  static Future<List<StopModel>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snaps = await Future.wait(
      ids.map((id) => firestore.collection(collectionName).doc(id).get()),
    );
    return snaps.where((s) => s.exists).map(StopModel.fromSnapshot).toList();
  }
}
