import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/constants/Strings.dart';
import 'package:indicab_driver/controllers/AuthController.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: Stack(
          children: [
            const _LoginBackdrop(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Obx(() => _Header(otpSent: controller.otpSent.value)),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Obx(
                          () => _LoginCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  controller.otpSent.value ? AppStrings.otp : AppStrings.login,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  controller.otpSent.value
                                      ? 'We have sent a 4-digit code to your number.'
                                      : 'Enter your number to receive a driver login code.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.45,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (!controller.otpSent.value) ...[
                                  _InputField(
                                    controller: controller.mobileController,
                                    hintText: AppStrings.mobile_number,
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: Icons.phone_iphone_rounded,
                                    maxLength: 10,
                                  ),
                                ] else ...[
                                  _InputField(
                                    controller: controller.otpController,
                                    hintText: 'Enter OTP',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.lock_outline_rounded,
                                    maxLength: 4,
                                  ),
                                ],
                                const SizedBox(height: 6),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: controller.errorMessage.value.isNotEmpty
                                      ? Padding(
                                          key: const ValueKey('error'),
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            controller.errorMessage.value,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(key: ValueKey('empty')),
                                ),
                                const SizedBox(height: 18),
                                _PrimaryActionButton(
                                  label: controller.otpSent.value
                                      ? 'Verify & Continue'
                                      : AppStrings.send_otp,
                                  isLoading: controller.isLoading.value,
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () {
                                          if (controller.otpSent.value) {
                                            controller.verifyOtp();
                                          } else {
                                            controller.sendOtp();
                                          }
                                        },
                                ),
                                if (controller.otpSent.value) ...[
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : controller.reset,
                                    child: const Text(
                                      'Change mobile number',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 18),
                                const _HintBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: _Footer(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD34D),
              Color(0xFFF8F8F5),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.otpSent});

  final bool otpSent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.local_taxi_rounded, color: AppColors.primary, size: 36),
        ),
        const SizedBox(height: 18),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          otpSent ? 'Almost there.' : AppStrings.title_tag,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.prefixIcon,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: AppColors.primaryDark),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9D37A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primaryDark, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Use OTP 1234 in this demo build.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '© 2026 IndiCab. All rights reserved.',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}