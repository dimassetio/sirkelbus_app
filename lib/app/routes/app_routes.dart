part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const AUTH = _Paths.AUTH;
  static const AUTH_LOGIN = _Paths.AUTH + _Paths.AUTH_LOGIN;
  static const USER_HOME = _Paths.USER_HOME;
  static const DRIVER_HOME = _Paths.DRIVER_HOME;
}

abstract class _Paths {
  _Paths._();

  static const AUTH = '/auth';
  static const AUTH_LOGIN = '/login';
  static const USER_HOME = '/user/home';
  static const DRIVER_HOME = '/driver/home';
}
