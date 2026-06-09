import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../controllers/auth_login_controller.dart';

class AuthLoginView extends GetView<AuthLoginController> {
  const AuthLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildFormCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
      child: Column(
        children: [
          Image.asset('assets/images/logo.png', width: 64, height: 64),
          const SizedBox(height: 16),
          Text(
            'SirkelBus',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Perjalanan lebih mudah',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selamat Datang',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Masuk untuk melanjutkan',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textCaption),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, size: 20, color: AppColors.textCaption),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline, size: 20, color: AppColors.textCaption),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            Obx(
              () => FilledButton(
                onPressed: controller.isLoading ? null : controller.signIn,
                child: controller.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Masuk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
