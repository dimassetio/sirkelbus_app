import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/login/bindings/auth_login_binding.dart';
import '../modules/auth/login/views/auth_login_view.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/driver/home/bindings/driver_home_binding.dart';
import '../modules/driver/home/views/driver_home_view.dart';
import '../modules/user/home/bindings/user_home_binding.dart';
import '../modules/user/home/views/user_home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.AUTH;

  static final routes = <GetPage>[
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
      ],
    ),
    GetPage(
      name: _Paths.USER_HOME,
      page: () => const UserHomeView(),
      binding: UserHomeBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_HOME,
      page: () => const DriverHomeView(),
      binding: DriverHomeBinding(),
    ),
  ];
}
