import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'remote_config_service.dart';

class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  late final Dio _dio;
  Dio get dio => _dio;

  void init() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Always read fresh from Remote Config — picks up URL changes without restart
        options.baseUrl = RemoteConfigService.instance.apiBaseUrl;

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }
}
