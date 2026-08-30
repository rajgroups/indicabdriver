import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/config/Config.dart';
import 'package:indicab_driver/constants/Keys.dart';
import 'package:indicab_driver/constants/Strings.dart';
import 'package:indicab_driver/network/client.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/services/SecureStorageService.dart';
import 'package:indicab_driver/services/SocketService.dart';
import 'package:indicab_driver/services/StorageService.dart';

// ─── Corporate Brand Palette ──────────────────────────────────────────────────
const _kBrandGreen = Color(0xFF00C853);
const _kBrandGreenDark = Color(0xFF009624);
const _kBrandGold = Color(0xFFFFB300);
const _kDarkSlate = Color(0xFF0F172A);
const _kSubtleSlate = Color(0xFF64748B);
const _kLightGrey = Color(0xFFE2E8F0);

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  bool _isNavigating = false;
  Timer? _failsafeTimer;

  late final AnimationController _mainAnimController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _mainAnimController,
      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: Curves.easeOutBack,
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _mainAnimController.forward();

    // ── Failsafe Timer ────────────────────────────────────────────────────────
    // Guarantees navigation even if storage or network calls stall unexpectedly
    final int delaySec = AppEnv.splashDelaySeconds;
    _failsafeTimer = Timer(Duration(seconds: delaySec + 5), () {
      _navigateToNextScreen(false);
    });

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final startTime = DateTime.now();
    bool isAuthorized = false;

    try {
      final secureStorage = SecureStorageService();
      final storage = StorageService();

      String? token;
      try {
        token = await secureStorage.read(StorageKeys.token);
      } catch (e) {
        debugPrint('[Splash] Secure storage read error: $e');
      }

      if (token == null || token.isEmpty) {
        final dynamic storedToken = storage.read(StorageKeys.token);
        if (storedToken != null && storedToken.toString().isNotEmpty) {
          token = storedToken.toString();
        }
      }

      dynamic driverId;
      try {
        driverId = storage.read('driverId');
        if (driverId == null || driverId.toString().isEmpty) {
          driverId = await secureStorage.read('driverId');
        }
      } catch (e) {
        debugPrint('[Splash] DriverId read error: $e');
      }

      isAuthorized = token != null &&
          token.isNotEmpty &&
          driverId != null &&
          driverId.toString().isNotEmpty;

      if (isAuthorized) {
        try {
          ApiClient().setTokens(token);
          if (Get.isRegistered<SocketService>()) {
            Get.find<SocketService>().setToken(token);
          }
        } catch (e) {
          debugPrint('[Splash] ApiClient / SocketService setToken error: $e');
        }
      }
    } catch (e) {
      debugPrint('[Splash] Auth check error: $e');
      isAuthorized = false;
    } finally {
      // Keep splash screen visible for configured duration (from env: SPLASH_DELAY_SECONDS)
      final elapsed = DateTime.now().difference(startTime);
      final targetDuration = Duration(seconds: AppEnv.splashDelaySeconds);
      final remaining = targetDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      _navigateToNextScreen(isAuthorized);
    }
  }

  void _navigateToNextScreen(bool isAuthorized) {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;
    _failsafeTimer?.cancel();

    if (isAuthorized) {
      Get.offAllNamed(RouteNames.home);
    } else {
      Get.offAllNamed(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _isNavigating = true;
    _failsafeTimer?.cancel();
    _mainAnimController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Ultra-Subtle Corporate Background Accents ───────────────────
            Positioned(
              top: -80,
              right: -80,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _kBrandGreen.withValues(
                            alpha: 0.05 + _pulseController.value * 0.03,
                          ),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _kBrandGold.withValues(
                            alpha:
                                0.04 + (1 - _pulseController.value) * 0.03,
                          ),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Main Corporate Branding & Center Content ────────────────────
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Corporate Emblem & Logo Container ──────────────────
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Subtle Ambient Pulse Ring in App Logo Green Color
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final double pulseScale =
                                  1.0 + (_pulseController.value * 0.08);
                              return Transform.scale(
                                scale: pulseScale,
                                child: Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _kBrandGreen.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Outer Ring Accent
                          Container(
                            width: 114,
                            height: 114,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _kBrandGreen.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                            ),
                          ),

                          // App Logo Container Card
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: _kBrandGreen.withValues(alpha: 0.18),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: _kLightGrey,
                                width: 1.2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/images/icons/app_icon.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/images/icons/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(
                                      Icons.local_taxi_rounded,
                                      size: 52,
                                      color: _kBrandGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Corporate Brand Title & Badge ─────────────────────
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.appName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: _kDarkSlate,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kBrandGreen, _kBrandGreenDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: _kBrandGreen.withValues(alpha: 0.30),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              "PARTNER",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Subtle Corporate Divider ───────────────────────────
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  _kBrandGreen.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.square_rounded,
                              size: 6,
                              color: _kBrandGold,
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _kBrandGreen.withValues(alpha: 0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Corporate Tagline ──────────────────────────────────
                      const Text(
                        'Enterprise Mobility & Driver Platform',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kSubtleSlate,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Loading Progress & Corporate Footer ─────────────────
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Loading Subtext
                  const Text(
                    'Initializing workspace...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _kSubtleSlate,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Premium Sleek Progress Bar in Logo Color
                  SizedBox(
                    width: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: const LinearProgressIndicator(
                        minHeight: 3.5,
                        backgroundColor: Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(_kBrandGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Corporate Footer Branding
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'MADE WITH ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _kSubtleSlate,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '❤️',
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        ' IN INDIA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _kBrandGold,
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
      ),
    );
  }
}
