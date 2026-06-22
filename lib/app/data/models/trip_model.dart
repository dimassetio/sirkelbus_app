import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/database.dart';

abstract class TripStatus {
  static const assigned = 'assigned';
  static const started = 'started';
  static const inProgress = 'in_progress';
  static const completed = 'completed';
  static const waiting = 'waiting';
}

class TripRouteStop {
  final String stopId;
  final String name;
  final int order;
  final int estimatedPassengers;

  TripRouteStop({
    required this.stopId,
    required this.name,
    required this.order,
    required this.estimatedPassengers,
  });

  factory TripRouteStop.fromMap(Map<String, dynamic> map) {
    return TripRouteStop(
      stopId: map['stopId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      estimatedPassengers: (map['estimatedPassengers'] as num?)?.toInt() ?? 0,
    );
  }
}

class TripProgress {
  final int currentStopIndex;
  final String? currentStopId;
  final String? nextStopId;
  final List<String> remainingStopIds;
  final bool capacityReached;
  final bool directToDestination;
  final List<String>? directRoutePath;
  final double? directRouteDistanceKm;

  TripProgress({
    required this.currentStopIndex,
    required this.currentStopId,
    required this.nextStopId,
    required this.remainingStopIds,
    required this.capacityReached,
    required this.directToDestination,
    this.directRoutePath,
    this.directRouteDistanceKm,
  });

  factory TripProgress.fromMap(Map<String, dynamic> map) {
    return TripProgress(
      currentStopIndex: (map['currentStopIndex'] as num?)?.toInt() ?? 0,
      currentStopId: map['currentStopId']?.toString(),
      nextStopId: map['nextStopId']?.toString(),
      remainingStopIds: (map['remainingStopIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      capacityReached: map['capacityReached'] == true,
      directToDestination: map['directToDestination'] == true,
      directRoutePath: (map['directRoutePath'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      directRouteDistanceKm: (map['directRouteDistanceKm'] as num?)
          ?.toDouble(),
    );
  }
}

class TripModel extends Database {
  static const collectionName = 'trips';

  String? id;
  String? scheduleId;
  String? routeTemplateName;
  String? serviceDate;
  String? driverId;
  String? busId;
  double? driverLatitude;
  double? driverLongitude;
  String? status;
  int? boardedCount;
  int? busCapacity;
  List<TripRouteStop>? routeStops;
  TripProgress? progress;
  DateTime? createdAt;

  TripModel({
    this.id,
    this.scheduleId,
    this.routeTemplateName,
    this.serviceDate,
    this.driverId,
    this.busId,
    this.driverLatitude,
    this.driverLongitude,
    this.status,
    this.boardedCount,
    this.busCapacity,
    this.routeStops,
    this.progress,
    this.createdAt,
  }) : super(collectionReference: firestore.collection(collectionName));

  TripModel.fromSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        super(collectionReference: firestore.collection(collectionName)) {
    final json = doc.data() as Map<String, dynamic>?;
    scheduleId = json?['scheduleId'];
    routeTemplateName = json?['routeTemplateName'] ?? json?['scheduleName'];
    serviceDate = json?['serviceDate'];
    driverId = json?['driverId'];
    busId = json?['busId'];
    driverLatitude = (json?['driverLatitude'] as num?)?.toDouble();
    driverLongitude = (json?['driverLongitude'] as num?)?.toDouble();
    status = json?['status'];
    boardedCount = (json?['boardedCount'] as num?)?.toInt();
    busCapacity = (json?['busCapacity'] as num?)?.toInt();
    routeStops = (json?['routeStops'] as List?)
        ?.map((e) => TripRouteStop.fromMap(e as Map<String, dynamic>))
        .toList();
    progress = json?['progress'] is Map
        ? TripProgress.fromMap(json?['progress'] as Map<String, dynamic>)
        : null;
    createdAt = json?['createdAt'] is Timestamp
        ? (json?['createdAt'] as Timestamp).toDate()
        : null;
  }

  bool get isActive =>
      status == TripStatus.started || status == TripStatus.inProgress;
  bool get hasLocation => driverLatitude != null && driverLongitude != null;
  int get passengerCount => boardedCount ?? 0;

  static Future<TripModel?> getById(String id) async {
    final doc = await firestore.collection(collectionName).doc(id).get();
    return doc.exists ? TripModel.fromSnapshot(doc) : null;
  }

  static Stream<TripModel?> streamById(String id) {
    return firestore
        .collection(collectionName)
        .doc(id)
        .snapshots()
        .map((snap) => snap.exists ? TripModel.fromSnapshot(snap) : null);
  }

  static Stream<List<TripModel>> streamByDriver(
      String driverId, String serviceDate) {
    return firestore
        .collection(collectionName)
        .where('driverId', isEqualTo: driverId)
        .where('serviceDate', isEqualTo: serviceDate)
        .snapshots()
        .map((snap) => snap.docs.map(TripModel.fromSnapshot).toList());
  }

  static Stream<TripModel?> streamByScheduleAndDate(
      String scheduleId, String serviceDate) {
    return firestore
        .collection(collectionName)
        .where('scheduleId', isEqualTo: scheduleId)
        .where('serviceDate', isEqualTo: serviceDate)
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : TripModel.fromSnapshot(snap.docs.first));
  }
}
