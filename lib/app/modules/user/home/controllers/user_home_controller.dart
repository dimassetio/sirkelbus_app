import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/booking_model.dart';
import '../../../auth/controllers/auth_controller.dart';

class UserHomeController extends GetxController {
  final todayBookings = <BookingModel>[].obs;

  StreamSubscription<List<BookingModel>>? _sub;

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    final uid = authC.firebaseUser.value?.uid;
    if (uid != null) {
      _sub = BookingModel.streamByUser(uid).listen((list) {
        todayBookings.assignAll(
          list.where((b) => b.serviceDate == _today).toList(),
        );
      });
    }
  }

  BookingModel? get topBooking =>
      todayBookings.isNotEmpty ? todayBookings.first : null;

  Future<void> signOut() => authC.signOut();

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
