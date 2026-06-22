import 'package:dio/dio.dart';

import '../models/booking_model.dart';
import '../services/api_client.dart';

class BookingProvider {
  BookingProvider._();
  static final instance = BookingProvider._();

  Dio get _dio => ApiClient.instance.dio;

  /// Returns (booking, errorMessage). One of them is always null.
  Future<(BookingModel?, String?)> createBooking({
    required String scheduleId,
    required String pickupStopId,
    required String serviceDate,
  }) async {
    try {
      final response = await _dio.post(
        '/user/bookings',
        data: {
          'scheduleId': scheduleId,
          'pickupStopId': pickupStopId,
          'serviceDate': serviceDate,
        },
      );
      print(response.data.runtimeType);
      print(response.data);
      print(response.data['booking'].runtimeType);
      print(response.data['booking']);
      final booking = BookingModel.fromJson(response.data['booking']);
      print("BOOKING!");
      print(booking);
      return (booking, null);
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map?)?['error'] as String? ??
          e.message ??
          'Gagal membuat booking';
      return (null, message);
    } catch (e) {
      print(e);
      return (null, e.toString());
    }
  }
}
