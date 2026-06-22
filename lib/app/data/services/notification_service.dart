import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/database.dart';
import '../models/user_model.dart';
import '../../routes/app_pages.dart';

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage _) async {
  // Background handler must be a top-level function.
  // Data-only processing can go here if needed later.
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onTap);

    // Handle notification tap when app was fully terminated
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onTap(initial);
  }

  /// Call after user login to persist FCM token and refresh on rotation.
  Future<void> saveToken(String userId) async {
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;
    await firestore
        .collection(UserModel.collectionName)
        .doc(userId)
        .update({'fcmToken': token});

    _messaging.onTokenRefresh.listen((t) {
      firestore
          .collection(UserModel.collectionName)
          .doc(userId)
          .update({'fcmToken': t});
    });
  }

  void _onForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    Get.snackbar(
      n.title ?? 'SirkelBus',
      n.body ?? '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1A2744),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      onTap: (_) => _navigateFromData(message.data),
    );
  }

  void _onTap(RemoteMessage message) => _navigateFromData(message.data);

  void _navigateFromData(Map<String, dynamic> data) {
    final bookingId = data['bookingId'] as String?;
    if (bookingId != null && bookingId.isNotEmpty) {
      Get.toNamed(Routes.USER_BOOKING_DETAIL, arguments: bookingId);
    }
  }
}
