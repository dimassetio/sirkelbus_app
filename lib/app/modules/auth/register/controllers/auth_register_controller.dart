import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../auth/controllers/auth_controller.dart';

class AuthRegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
    if (v != passwordController.text) return 'Password tidak sama';
    return null;
  }

  Future<void> signUp() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    try {
      _isLoading.value = true;
      final error = await authC.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );
      if (error == null) {
        Get.offAllNamed(Routes.USER_HOME);
        Get.snackbar('Berhasil', 'Selamat datang, ${authC.user.name}');
      } else {
        Get.snackbar('Gagal mendaftar', error);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }
}
