import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/login/bindings/auth_login_binding.dart';
import '../modules/auth/login/views/auth_login_view.dart';
import '../modules/auth/register/bindings/auth_register_binding.dart';
import '../modules/auth/register/views/auth_register_view.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/driver/home/bindings/driver_home_binding.dart';
import '../modules/driver/home/views/driver_home_view.dart';
import '../modules/driver/route_preview/bindings/driver_route_preview_binding.dart';
import '../modules/driver/route_preview/views/driver_route_preview_view.dart';
import '../modules/driver/scan/bindings/driver_scan_binding.dart';
import '../modules/driver/scan/views/driver_scan_view.dart';
import '../modules/driver/trip_detail/bindings/driver_trip_detail_binding.dart';
import '../modules/driver/trip_detail/views/driver_trip_detail_view.dart';
import '../modules/user/home/bindings/user_home_binding.dart';
import '../modules/user/home/views/user_home_view.dart';
import '../modules/user/schedule/bindings/user_schedule_binding.dart';
import '../modules/user/schedule/views/user_schedule_view.dart';
import '../modules/user/booking_detail/bindings/booking_detail_binding.dart';
import '../modules/user/booking_detail/views/booking_detail_view.dart';
import '../modules/user/scan/bindings/scan_binding.dart';
import '../modules/user/scan/views/scan_view.dart';
import '../modules/user/stop_map/bindings/stop_map_binding.dart';
import '../modules/user/stop_map/views/stop_map_view.dart';
import '../modules/user/profile/bindings/user_profile_binding.dart';
import '../modules/user/profile/views/user_profile_view.dart';
import '../modules/user/ticket/bindings/user_ticket_binding.dart';
import '../modules/user/ticket/views/user_ticket_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.AUTH;

  static final routes = <GetPage>[
    // Auth
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
      children: [
        GetPage(
          name: _Paths.AUTH_LOGIN,
          page: () => const AuthLoginView(),
          binding: AuthLoginBinding(),
        ),
        GetPage(
          name: _Paths.AUTH_REGISTER,
          page: () => const AuthRegisterView(),
          binding: AuthRegisterBinding(),
        ),
      ],
    ),

    // User home — flat, no children; each sub-page is a top-level route
    GetPage(
      name: _Paths.USER_HOME,
      page: () => const UserHomeView(),
      binding: UserHomeBinding(),
    ),
    GetPage(
      name: Routes.USER_SCHEDULE,
      page: () => const UserScheduleView(),
      binding: UserScheduleBinding(),
    ),
    GetPage(
      name: Routes.USER_TICKET,
      page: () => const UserTicketView(),
      binding: UserTicketBinding(),
    ),
    GetPage(
      name: Routes.USER_STOP_MAP,
      page: () => const StopMapView(),
      binding: StopMapBinding(),
    ),
    GetPage(
      name: Routes.USER_BOOKING_DETAIL,
      page: () => const BookingDetailView(),
      binding: BookingDetailBinding(),
    ),
    GetPage(
      name: Routes.USER_SCAN,
      page: () => const ScanView(),
      binding: ScanBinding(),
    ),
    GetPage(
      name: Routes.USER_PROFILE,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
    ),

    // Driver
    GetPage(
      name: _Paths.DRIVER_HOME,
      page: () => const DriverHomeView(),
      binding: DriverHomeBinding(),
    ),
    GetPage(
      name: Routes.DRIVER_TRIP_DETAIL,
      page: () => const DriverTripDetailView(),
      binding: DriverTripDetailBinding(),
    ),
    GetPage(
      name: Routes.DRIVER_SCAN,
      page: () => const DriverScanView(),
      binding: DriverScanBinding(),
    ),
    GetPage(
      name: Routes.DRIVER_ROUTE_PREVIEW,
      page: () => const DriverRoutePreviewView(),
      binding: DriverRoutePreviewBinding(),
    ),
  ];
}
