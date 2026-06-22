import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../services/api_client.dart';

class DriverCheckInProvider {
  DriverCheckInProvider._();
  static final instance = DriverCheckInProvider._();

  Dio get _dio => ApiClient.instance.dio;

  Future<bool> checkIn(String tripId, String bookingId) async {
    try {
      await _dio.post(
        '/trips/$tripId/check-in',
        data: {'bookingId': bookingId},
      );
      return true;
    } on DioException catch (e) {
      final message = (e.response?.data as Map?)?['error'] as String? ??
          e.message ??
          'Terjadi kesalahan.';
      Get.snackbar(
        'Gagal Check-In',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Gagal Check-In',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
