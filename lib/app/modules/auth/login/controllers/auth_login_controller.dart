import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/controllers/auth_controller.dart';
import '../../../../routes/app_pages.dart';

class AuthLoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    try {
      _isLoading.value = true;
      final error = await authC.signIn(
        emailController.text.trim(),
        passwordController.text,
      );
      if (error == null) {
        if (authC.user.isDriver) {
          Get.offAllNamed(Routes.DRIVER_HOME);
        } else {
          Get.offAllNamed(Routes.USER_HOME);
        }
        Get.snackbar('Berhasil', 'Selamat datang, ${authC.user.name}');
      } else {
        Get.snackbar('Gagal masuk', error);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }
}
