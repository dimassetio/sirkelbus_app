part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const AUTH = _Paths.AUTH;
  static const AUTH_LOGIN = _Paths.AUTH + _Paths.AUTH_LOGIN;
  static const AUTH_REGISTER = _Paths.AUTH + _Paths.AUTH_REGISTER;
  static const USER_HOME = _Paths.USER_HOME;
  static const USER_SCHEDULE = _Paths.USER_HOME + _Paths.USER_SCHEDULE;
  static const USER_TICKET = _Paths.USER_HOME + _Paths.USER_TICKET;
  static const USER_STOP_MAP = _Paths.USER_HOME + _Paths.USER_STOP_MAP;
  static const USER_BOOKING_DETAIL = _Paths.USER_HOME + _Paths.USER_BOOKING_DETAIL;
  static const USER_SCAN = _Paths.USER_HOME + _Paths.USER_SCAN;
  static const USER_PROFILE = _Paths.USER_HOME + _Paths.USER_PROFILE;
  static const DRIVER_HOME = _Paths.DRIVER_HOME;
  static const DRIVER_TRIP_DETAIL = _Paths.DRIVER_HOME + _Paths.DRIVER_TRIP_DETAIL;
  static const DRIVER_SCAN = _Paths.DRIVER_HOME + _Paths.DRIVER_SCAN;
  static const DRIVER_ROUTE_PREVIEW = _Paths.DRIVER_HOME + _Paths.DRIVER_ROUTE_PREVIEW;
}

abstract class _Paths {
  _Paths._();

  static const AUTH = '/auth';
  static const AUTH_LOGIN = '/login';
  static const AUTH_REGISTER = '/register';
  static const USER_HOME = '/user/home';
  static const USER_SCHEDULE = '/schedule';
  static const USER_TICKET = '/ticket';
  static const USER_STOP_MAP = '/stop-map';
  static const USER_BOOKING_DETAIL = '/booking-detail';
  static const USER_SCAN = '/scan';
  static const USER_PROFILE = '/profile';
  static const DRIVER_HOME = '/driver/home';
  static const DRIVER_TRIP_DETAIL = '/trip-detail';
  static const DRIVER_SCAN = '/scan';
  static const DRIVER_ROUTE_PREVIEW = '/route-preview';
}
