import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/database.dart';

abstract class Role {
  static const user = 'user';
  static const driver = 'driver';
  static const admin = 'admin';
}

class UserModel extends Database {
  static const collectionName = 'users';

  String? id;
  String? name;
  String? email;
  String? phone;
  String? role;
  String? fcmToken;
  bool? isActive;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.fcmToken,
    this.isActive,
  }) : super(collectionReference: firestore.collection(collectionName));

  UserModel.fromSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        super(collectionReference: firestore.collection(collectionName)) {
    final json = doc.data() as Map<String, dynamic>?;
    name = json?['name'];
    email = json?['email'];
    phone = json?['phone'];
    role = json?['role'];
    fcmToken = json?['fcmToken'];
    isActive = json?['isActive'];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'fcmToken': fcmToken,
        'isActive': isActive,
      };

  bool get isDriver => role == Role.driver;

  Future<UserModel?> getUser() async {
    if (id == null || id!.isEmpty) return null;
    final doc = await getID(id!);
    if (!doc.exists) return null;
    return UserModel.fromSnapshot(doc);
  }

  Stream<UserModel> stream() {
    return collectionReference
        .doc(id)
        .snapshots()
        .map(UserModel.fromSnapshot);
  }
}
