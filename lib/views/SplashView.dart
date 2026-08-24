import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/constants/Keys.dart';
import 'package:indicab_driver/constants/Strings.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';
import 'package:indicab_driver/services/SocketService.dart';
import 'package:indicab_driver/services/StorageService.dart';

// ─── Rapido-style palette ────────────────────────────────────────────────────
const _kNavy  = Color(0xFF1A1A2E);
const _kGreen = Color(0xFF00C853);
const _kAmber = Color(0xFFFFB300);
const _kMuted = Color(0xFFB0B3C1);

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  bool _isNavigating = false;

  late final AnimationController _mainAnimController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _mainAnimController,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _mainAnimController.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final startTime = DateTime.now();

    final secureStorage = SecureStorageService();
    final storage = StorageService();

    String? token = await secureStorage.read(StorageKeys.token);
    if (token == null || token.isEmpty) {
      final dynamic storedToken = storage.read(StorageKeys.token);
      if (storedToken != null && storedToken.toString().isNotEmpty) {
        token = storedToken.toString();
      }
    }

    dynamic driverId = storage.read('driverId');
    if (driverId == null || driverId.toString().isEmpty) {
      driverId = await secureStorage.read('driverId');
    }

    final bool isAuthorized = token != null &&
        token.isNotEmpty &&
        driverId != null &&
        driverId.toString().isNotEmpty;

    if (isAuthorized) {
      ApiClient().setTokens(token);
      if (Get.isRegistered<SocketService>()) {
        Get.find<SocketService>().setToken(token);
      }
    }

    // Keep splash visible for at least 2 seconds for a smooth user experience
    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(milliseconds: 2000) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted || _isNavigating) return;
    _isNavigating = true;

    if (isAuthorized) {
      Get.offAllNamed(RouteNames.home);
    } else {
      Get.offAllNamed(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _isNavigating = true;
    _mainAnimController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      body: Stack(
        children: [
          // ── Background Glow Blobs ─────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kGreen.withValues(alpha: 0.12),
                    blurRadius: 70,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kAmber.withValues(alpha: 0.10),
                    blurRadius: 80,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // ── Center Branding & Content ──────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Animated Traditional Mandala Ring + App Emblem ───
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating Traditional Mandala Ring
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationController.value * math.pi * 2,
                              child: CustomPaint(
                                size: const Size(160, 160),
                                painter: _TraditionalMandalaPainter(),
                              ),
                            );
                          },
                        ),

                        // Center Emblem Box
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF009624)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: _kGreen.withValues(alpha: 0.40),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/images/icons/app_icon.png',
                              width: 104,
                              height: 104,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.local_taxi_rounded,
                                size: 54,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Brand Title ────────────────────────────────────────
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.appName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _kGreen,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _kGreen.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            "PARTNER",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Traditional Accent Divider ─────────────────────────
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _kGreen.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: _kAmber,
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _kGreen.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── Tagline ─────────────────────────────────────────────
                    Text(
                      'Drive & Earn on Your Schedule',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.70),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Loading Bar & Made in India ─────────────────────────
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        _kGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'MADE WITH ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '❤️',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      ' IN INDIA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kAmber,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Traditional Mandala Decorative Aura Painter ─────────────────────────────
class _TraditionalMandalaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _kGreen.withValues(alpha: 0.35);

    final goldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _kAmber.withValues(alpha: 0.40);

    // Outer circle
    canvas.drawCircle(center, radius - 2, linePaint);

    // Inner dashed circle
    canvas.drawCircle(center, radius - 12, goldPaint);

    // 8 Traditional Lotus / Mandala Petals
    const numPetals = 8;
    for (var i = 0; i < numPetals; i++) {
      final angle = (i * 2 * math.pi) / numPetals;
      final x1 = center.dx + (radius - 2) * math.cos(angle);
      final y1 = center.dy + (radius - 2) * math.sin(angle);
      canvas.drawCircle(
        Offset(x1, y1),
        3,
        Paint()..color = _kAmber.withValues(alpha: 0.70),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
