import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/database.dart';

abstract class BookingStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const cancelled = 'cancelled';
  static const completed = 'completed';
}

class BookingModel extends Database {
  static const collectionName = 'bookings';

  String? id;
  String? userId;
  String? scheduleId;
  String? pickupStopId;
  String? serviceDate; // "YYYY-MM-DD"
  String? status;
  String? source;
  String? note;
  String? tripId;
  String? boardedAt;
  String? boardedTripId;
  String? boardedBy;
  String? checkInBarcode;
  DateTime? createdAt;

  BookingModel({
    this.id,
    this.userId,
    this.scheduleId,
    this.pickupStopId,
    this.serviceDate,
    this.status,
    this.source,
    this.note,
    this.tripId,
    this.boardedAt,
    this.boardedTripId,
    this.boardedBy,
    this.checkInBarcode,
    this.createdAt,
  }) : super(collectionReference: firestore.collection(collectionName));

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['userId'],
      scheduleId: json['scheduleId'],
      pickupStopId: json['pickupStopId'],
      serviceDate: json['serviceDate'],
      status: json['status'],
      source: json['source'],
      note: json['note'],
      tripId: json['tripId'],
      boardedAt: json['boardedAt'],
      boardedTripId: json['boardedTripId'],
      boardedBy: json['boardedBy'],
      checkInBarcode: json['checkInBarcode'],
      createdAt: json['createdAt'] is String?
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  BookingModel.fromSnapshot(DocumentSnapshot doc)
    : id = doc.id,
      super(collectionReference: firestore.collection(collectionName)) {
    final json = doc.data() as Map<String, dynamic>?;
    userId = json?['userId'];
    scheduleId = json?['scheduleId'];
    pickupStopId = json?['pickupStopId'];
    serviceDate = json?['serviceDate'];
    status = json?['status'];
    source = json?['source'];
    note = json?['note'];
    tripId = json?['tripId'];
    boardedTripId = json?['boardedTripId'];
    boardedBy = json?['boardedBy'];
    checkInBarcode = json?['checkInBarcode'];
    boardedAt = json?['boardedAt'] is Timestamp
        ? (json?['boardedAt'] as Timestamp).toDate().toIso8601String()
        : json?['boardedAt'];
    createdAt = json?['createdAt'] is Timestamp
        ? (json?['createdAt'] as Timestamp).toDate()
        : null;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'scheduleId': scheduleId,
    'pickupStopId': pickupStopId,
    'serviceDate': serviceDate,
    'status': status,
    'source': source,
    'note': note,
  };

  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isBoarded => boardedAt != null && boardedAt!.isNotEmpty;

  static Stream<BookingModel?> streamById(String id) {
    return firestore
        .collection(collectionName)
        .doc(id)
        .snapshots()
        .map((snap) => snap.exists ? BookingModel.fromSnapshot(snap) : null);
  }

  static Stream<List<BookingModel>> streamByUser(String userId) {
    return firestore
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromSnapshot).toList());
  }

  static Future<List<BookingModel>> getActiveForSchedule({
    required String scheduleId,
    required String serviceDate,
  }) async {
    final snap = await firestore
        .collection(collectionName)
        .where('scheduleId', isEqualTo: scheduleId)
        .where('serviceDate', isEqualTo: serviceDate)
        .where('status',
            whereIn: [BookingStatus.pending, BookingStatus.confirmed])
        .get();
    return snap.docs.map(BookingModel.fromSnapshot).toList();
  }
}
