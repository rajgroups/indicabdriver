import 'package:flutter/material.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/constants/Strings.dart';

/// Top hero card integrating the Brand Icon, Brand Name, Title Tag, Sub Tag,
/// vector taxi background graphic, and feature pills inside a single cohesive card.
class LoginIllustration extends StatelessWidget {
  const LoginIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF5B800).withValues(alpha: 0.12),
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
                painter: _LoginTopHeroVectorPainter(),
              ),
            ),

            /// Foreground Content (Brand Icon, Brand Name, Title & Sub Tag)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Top Row: Brand Icon + Brand Name & Driver Partner Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF5B800), Color(0xFFE6A700)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF5B800).withValues(alpha: 0.35),
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
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.appName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'SF Pro Text',
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                "PARTNER",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: AppColors.primaryDark,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      /// Driver Partner Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFFD54F),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_car_filled_rounded, size: 13, color: Color(0xFFB88400)),
                            SizedBox(width: 4),
                            Text(
                              "Driver Portal",
                              style: TextStyle(
                                color: Color(0xFFB88400),
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

                  /// Driver Specific Title Tag
                  const Text(
                    "Drive & Earn on Your Schedule",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontFamily: 'SF Pro Display',
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Driver Specific Sub Tag
                  Text(
                    "Accept trip requests, track daily earnings & maximize revenue.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'SF Pro Text',
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Driver Specific Feature Badges
                  Row(
                    children: [
                      _HeroBadgeChip(
                        icon: Icons.payments_rounded,
                        iconColor: const Color(0xFF2E7D32),
                        text: "Daily Payouts",
                      ),
                      const SizedBox(width: 8),
                      _HeroBadgeChip(
                        icon: Icons.verified_user_rounded,
                        iconColor: const Color(0xFFB88400),
                        text: "Low Commission",
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

class _HeroBadgeChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _HeroBadgeChip({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
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
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Vector Painter for top background graphics
class _LoginTopHeroVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Ambient radial glow
    final bgGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF8E1).withValues(alpha: 0.7),
          const Color(0xFFFFFFFF),
        ],
        center: Alignment.topRight,
        radius: 1.1,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgGlowPaint);

    // City skyline at lower bottom of top card
    final skylinePaint = Paint()..color = const Color(0xFFF3F0E6);
    final skylinePath = Path();
    skylinePath.moveTo(0, height * 0.75);

    final buildingWidths = [24.0, 18.0, 28.0, 20.0, 32.0, 22.0, 28.0, 36.0, 26.0];
    final buildingHeights = [30.0, 48.0, 36.0, 60.0, 42.0, 52.0, 34.0, 48.0, 32.0];

    double currentX = width * 0.3;
    for (int i = 0; i < buildingWidths.length && currentX < width; i++) {
      final bWidth = buildingWidths[i];
      final bHeight = buildingHeights[i];
      final topY = height * 0.75 - bHeight;

      skylinePath.lineTo(currentX, topY);
      skylinePath.lineTo(currentX + bWidth, topY);
      currentX += bWidth;
    }
    skylinePath.lineTo(width, height * 0.75);
    skylinePath.lineTo(width, height);
    skylinePath.lineTo(width * 0.3, height);
    skylinePath.close();

    canvas.drawPath(skylinePath, skylinePaint);

    // Curved road accent at bottom right
    final roadPaint = Paint()..color = const Color(0xFF3B3B3B);
    final roadPath = Path();
    roadPath.moveTo(width * 0.45, height);
    roadPath.cubicTo(
      width * 0.6, height * 0.85,
      width * 0.8, height * 0.88,
      width, height * 0.82,
    );
    roadPath.lineTo(width, height);
    roadPath.close();
    canvas.drawPath(roadPath, roadPaint);

    // Golden lane line
    final lanePaint = Paint()
      ..color = const Color(0xFFF5B800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final lanePath = Path();
    lanePath.moveTo(width * 0.48, height);
    lanePath.cubicTo(
      width * 0.62, height * 0.88,
      width * 0.82, height * 0.91,
      width, height * 0.85,
    );
    canvas.drawPath(lanePath, lanePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
