import 'package:flutter/material.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/constants/Strings.dart';

// ─── Rapido-style palette ────────────────────────────────────────────────────
const _kNavy  = Color(0xFF1A1A2E);
const _kGreen = Color(0xFF00C853);
const _kAmber = Color(0xFFFFB300);

/// Top hero card for OTP screen — Rapido partner app style with navy header.
class OtpIllustration extends StatelessWidget {
  final String maskedMobile;
  final VoidCallback onEditMobile;

  const OtpIllustration({
    super.key,
    required this.maskedMobile,
    required this.onEditMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEEFF3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.10),
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            /// Vector Art Background Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: _OtpTopHeroVectorPainter(),
              ),
            ),

            /// Foreground Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Top Row: Brand Icon + Brand Name & Status Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: _kNavy,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _kNavy.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/icons/app_icon.png',
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.local_taxi_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.appName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: _kNavy,
                                  height: 1.1,
                                ),
                              ),
                              const Text(
                                "PARTNER",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: _kGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      /// Driver Verification Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _kGreen.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                size: 13, color: _kGreen),
                            const SizedBox(width: 4),
                            Text(
                              "Driver Verification",
                              style: TextStyle(
                                color: _kGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// Title
                  const Text(
                    "Verify Driver OTP Code",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _kNavy,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Masked Phone + Edit Button
                  Row(
                    children: [
                      Text(
                        "Driver code sent to $maskedMobile",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB0B3C1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onEditMobile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _kNavy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 11,
                                color: _kNavy,
                              ),
                              SizedBox(width: 3),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _kNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// Feature Chips
                  Row(
                    children: [
                      _OtpHeroBadgeChip(
                        icon: Icons.verified_user_rounded,
                        iconColor: _kGreen,
                        text: "Verified Driver",
                      ),
                      const SizedBox(width: 8),
                      _OtpHeroBadgeChip(
                        icon: Icons.speed_rounded,
                        iconColor: const Color(0xFF1976D2),
                        text: "Instant Trip Access",
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

class _OtpHeroBadgeChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _OtpHeroBadgeChip({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEEEFF3),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: _kNavy,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Vector Painter — Rapido-style navy & green accents
class _OtpTopHeroVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Ambient radial glow — subtle navy tint
    final bgGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _kNavy.withValues(alpha: 0.04),
          const Color(0xFFFFFFFF),
        ],
        center: Alignment.topRight,
        radius: 0,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgGlowPaint);

    final shieldCenterX = width * 0.85;
    final shieldCenterY = height * 0.55;

    // Signal rings — green pulse
    final pulseRing1 = Paint()
      ..color = _kGreen.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(shieldCenterX, shieldCenterY), 38, pulseRing1);

    final pulseRing2 = Paint()
      ..color = _kGreen.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(shieldCenterX, shieldCenterY), 54, pulseRing2);

    // Shield Graphic — navy with green glow
    final shieldPath = Path();
    final sTop = shieldCenterY - 18;
    final sWidth = 32.0;
    final sHeight = 38.0;

    shieldPath.moveTo(shieldCenterX, sTop);
    shieldPath.cubicTo(
      shieldCenterX + sWidth * 0.5, sTop,
      shieldCenterX + sWidth * 0.5, sTop + sHeight * 0.4,
      shieldCenterX + sWidth * 0.5, sTop + sHeight * 0.55,
    );
    shieldPath.cubicTo(
      shieldCenterX + sWidth * 0.5, sTop + sHeight * 0.85,
      shieldCenterX, sTop + sHeight,
      shieldCenterX, sTop + sHeight,
    );
    shieldPath.cubicTo(
      shieldCenterX, sTop + sHeight,
      shieldCenterX - sWidth * 0.5, sTop + sHeight * 0.85,
      shieldCenterX - sWidth * 0.5, sTop + sHeight * 0.55,
    );
    shieldPath.cubicTo(
      shieldCenterX - sWidth * 0.5, sTop + sHeight * 0.4,
      shieldCenterX - sWidth * 0.5, sTop,
      shieldCenterX, sTop,
    );
    shieldPath.close();

    final shieldGradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1A1A2E), Color(0xFF2D2D4E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(
          shieldCenterX - sWidth / 2, sTop, sWidth, sHeight));

    canvas.drawPath(shieldPath, shieldGradientPaint);

    // Green check on shield
    final checkPaint = Paint()
      ..color = _kGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final checkPath = Path();
    checkPath.moveTo(shieldCenterX - 6, shieldCenterY + 1);
    checkPath.lineTo(shieldCenterX - 1, shieldCenterY + 6);
    checkPath.lineTo(shieldCenterX + 8, shieldCenterY - 4);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
