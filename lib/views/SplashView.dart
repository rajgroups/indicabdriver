import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/constants/Strings.dart';
import 'package:indicab_driver/routes/names.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Smooth transition to Login screen after 2.5 seconds
    _timer = Timer(const Duration(milliseconds: 2500), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Get.offAllNamed(RouteNames.login);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// Ambient Radial Warm Glow Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFBF0),
                      Color(0xFFFFFFFF),
                      Color(0xFFFFF9E6),
                    ],
                  ),
                ),
              ),
            ),

            /// CENTER BRAND LOGO & TITLE
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// App Icon Logo Container
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFF5B800).withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF5B800).withValues(alpha: 0.25),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/icons/app_icon.png',
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.local_taxi_rounded,
                          color: AppColors.black,
                          size: 58,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: const Duration(milliseconds: 400)),

                  const SizedBox(height: 24),

                  /// Brand Name Header
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.appName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: AppColors.textPrimary,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF5B800), Color(0xFFE6A700)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF5B800).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          "PARTNER",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 500)).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 8),

                  /// Driver Partner Subtitle
                  const Text(
                    "Drive & Earn on Your Schedule",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 350), duration: const Duration(milliseconds: 500)),
                ],
              ),
            ),

            /// BOTTOM LOADER & PULSING TEXT
            Positioned(
              bottom: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF5B800).withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFF5B800),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Loading IndiCab Partner...",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .fadeIn(duration: const Duration(milliseconds: 700))
                      .then()
                      .fadeOut(duration: const Duration(milliseconds: 700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
