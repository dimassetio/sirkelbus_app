import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/database.dart';

class ScheduleModel extends Database {
  static const collectionName = 'schedules';

  String? id;
  String? name;
  String? routeId;
  String? routeDirection;
  String? departureTime; // "HH:MM"
  String? arrivalTimeEstimate; // "HH:MM"
  int? arrivalEstimateMinutes;
  String? busId;
  List<String> busIds;
  String? driverId;
  List<String> driverIds;
  int? capacity;
  String? bookingOpenAt;
  String? bookingCloseAt;
  String? bookingOpenHour;  // "HH:MM"
  String? bookingCloseHour; // "HH:MM"
  bool? repeatDaily;
  List<String> disabledDays;

  ScheduleModel({
    this.id,
    this.name,
    this.routeId,
    this.routeDirection,
    this.departureTime,
    this.arrivalTimeEstimate,
    this.arrivalEstimateMinutes,
    this.busId,
    this.busIds = const [],
    this.driverId,
    this.driverIds = const [],
    this.capacity,
    this.bookingOpenAt,
    this.bookingCloseAt,
    this.bookingOpenHour,
    this.bookingCloseHour,
    this.repeatDaily,
    this.disabledDays = const [],
  }) : super(collectionReference: firestore.collection(collectionName));

  ScheduleModel.fromSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        busIds = const [],
        driverIds = const [],
        disabledDays = const [],
        super(collectionReference: firestore.collection(collectionName)) {
    final json = doc.data() as Map<String, dynamic>?;
    name = json?['name'];
    routeId = json?['routeId'];
    routeDirection = json?['routeDirection'];
    departureTime = json?['departureTime'];
    arrivalTimeEstimate = json?['arrivalTimeEstimate'];
    arrivalEstimateMinutes = (json?['arrivalEstimateMinutes'] as num?)?.toInt();
    busId = json?['busId'];
    busIds = List<String>.from(json?['busIds'] ?? []);
    driverId = json?['driverId'];
    driverIds = List<String>.from(json?['driverIds'] ?? []);
    capacity = (json?['capacity'] as num?)?.toInt();
    bookingOpenAt = json?['bookingOpenAt'];
    bookingCloseAt = json?['bookingCloseAt'];
    bookingOpenHour = json?['bookingOpenHour'];
    bookingCloseHour = json?['bookingCloseHour'];
    repeatDaily = json?['repeatDaily'];
    disabledDays = List<String>.from(json?['disabledDays'] ?? []);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'routeId': routeId,
        'departureTime': departureTime,
        'capacity': capacity,
        'busId': busId,
        'busIds': busIds,
        'driverId': driverId,
        'driverIds': driverIds,
        'repeatDaily': repeatDaily,
        'disabledDays': disabledDays,
        'bookingOpenHour': bookingOpenHour,
        'bookingCloseHour': bookingCloseHour,
      };

  // Whether booking window is still open for a given date (YYYY-MM-DD)
  bool isBookingOpen(String serviceDate) {
    final closeHour = bookingCloseHour;
    if (closeHour == null || closeHour.isEmpty) return true;
    final parts = closeHour.split(':');
    if (parts.length < 2) return true;
    final closeTime = DateTime.tryParse('${serviceDate}T$closeHour:00');
    if (closeTime == null) return true;
    return DateTime.now().isBefore(closeTime);
  }

  // Whether this schedule runs on the given date (respects disabledDays)
  bool runsOn(DateTime date) {
    const weekdays = [
      'monday', 'tuesday', 'wednesday', 'thursday',
      'friday', 'saturday', 'sunday',
    ];
    final dayName = weekdays[date.weekday - 1];
    return !disabledDays.contains(dayName);
  }

  static Stream<List<ScheduleModel>> streamAll() {
    return firestore
        .collection(collectionName)
        .orderBy('departureTime')
        .snapshots()
        .map((snap) => snap.docs.map(ScheduleModel.fromSnapshot).toList());
  }
}
