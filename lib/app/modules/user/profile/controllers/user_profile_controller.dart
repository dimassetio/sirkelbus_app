import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/helpers/database.dart';
import '../../../../data/models/user_model.dart';
import '../../../auth/controllers/auth_controller.dart';

class UserProfileController extends GetxController {
  final isEditing = false.obs;
  final isSaving = false.obs;

  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController(text: authC.user.name ?? '');
    phoneCtrl = TextEditingController(text: authC.user.phone ?? '');
  }

  void toggleEdit() {
    if (isEditing.value) {
      // Cancel — reset to current values
      nameCtrl.text = authC.user.name ?? '';
      phoneCtrl.text = authC.user.phone ?? '';
    }
    isEditing.toggle();
  }

  Future<void> save() async {
    final uid = authC.firebaseUser.value?.uid;
    if (uid == null) return;

    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Nama wajib diisi', '',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving(true);
    try {
      await firestore
          .collection(UserModel.collectionName)
          .doc(uid)
          .update({'name': name, 'phone': phone});
      isEditing(false);
      Get.snackbar('Tersimpan', 'Profil berhasil diperbarui.',
          snackPosition: SnackPosition.BOTTOM);
    } on FirebaseException catch (e) {
      Get.snackbar('Gagal', e.message ?? 'Terjadi kesalahan.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving(false);
    }
  }

  Future<void> signOut() => authC.signOut();

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}
