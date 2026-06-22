import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.toggleEdit,
                child: Text(
                  controller.isEditing.value ? 'Batal' : 'Edit',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _AvatarSection(),
            const SizedBox(height: 32),
            _ProfileForm(controller: controller),
            const SizedBox(height: 32),
            _SignOutButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar
// ---------------------------------------------------------------------------

class _AvatarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = authC.user.name ?? '';
      final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
      return Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authC.user.email ?? '',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textCaption,
            ),
          ),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Profile form
// ---------------------------------------------------------------------------

class _ProfileForm extends StatelessWidget {
  final UserProfileController controller;
  const _ProfileForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final editing = controller.isEditing.value;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            _FieldRow(
              icon: Icons.person_outline_rounded,
              label: 'Nama',
              controller: controller.nameCtrl,
              enabled: editing,
            ),
            const Divider(height: 28),
            _FieldRow(
              icon: Icons.email_outlined,
              label: 'Email',
              staticValue: authC.user.email ?? '-',
              enabled: false,
            ),
            const Divider(height: 28),
            _FieldRow(
              icon: Icons.phone_outlined,
              label: 'Nomor HP',
              controller: controller.phoneCtrl,
              enabled: editing,
              keyboardType: TextInputType.phone,
            ),
            if (editing) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.save,
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Simpan Perubahan'),
                    )),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController? controller;
  final String? staticValue;
  final bool enabled;
  final TextInputType keyboardType;

  const _FieldRow({
    required this.icon,
    required this.label,
    this.controller,
    this.staticValue,
    required this.enabled,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.navyLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.navy),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textCaption),
              ),
              const SizedBox(height: 4),
              if (controller != null)
                TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: enabled
                        ? const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10)
                        : EdgeInsets.zero,
                    border: enabled
                        ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          )
                        : InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.navy, width: 2),
                    ),
                    disabledBorder: InputBorder.none,
                  ),
                )
              else
                Text(
                  staticValue ?? '-',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sign-out
// ---------------------------------------------------------------------------

class _SignOutButton extends StatelessWidget {
  final UserProfileController controller;
  const _SignOutButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.signOut,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Keluar'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
