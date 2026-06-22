import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  RemoteConfigService._();
  static final instance = RemoteConfigService._();

  final _rc = FirebaseRemoteConfig.instance;

  static const _keyApiBaseUrl = 'api_base_url';

  String get apiBaseUrl => _rc.getString(_keyApiBaseUrl);

  Future<void> init() async {
    await _rc.setDefaults(const {
      _keyApiBaseUrl: 'https://admin-sirkelbus.vercel.app/api',
    });

    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      // In debug we fetch fresh every time; in prod, max once per hour
      minimumFetchInterval:
          kDebugMode ? Duration.zero : const Duration(hours: 1),
    ));

    await _rc.fetchAndActivate();
  }
}
