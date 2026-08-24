import 'package:flutter/material.dart';

/// A premium Modern Traditional Indian aesthetic card displayed on the Home Screen
/// when the driver's wallet balance reaches zero (₹0.00).
class ModernTraditionalZeroWalletCard extends StatelessWidget {
  const ModernTraditionalZeroWalletCard({
    super.key,
    required this.onRecharge,
    this.balance = 0.0,
  });

  final VoidCallback onRecharge;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _TraditionalArchPainter(
        color: Color(0xFFC49A2A),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFDF7), Color(0xFFFFF4D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB88400).withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF8A1C0E).withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Royal Traditional Header Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A1C0E), Color(0xFFB82614)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE5B54F),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A1C0E).withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFFFD76A),
                        size: 11,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'ACCOUNT ALERT • ACTION REQUIRED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                // Corner Ornament Accent Text
                Row(
                  children: const [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF9E7B27),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Zero Balance',
                      style: TextStyle(
                        color: Color(0xFF8A6411),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle Section: Icon Emblem + Detailed Notice + Balance Tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Traditional Embossed Wallet Emblem
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D2403), Color(0xFF704709)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5B54F),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3D2403).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFFFFD76A),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title and Subtitle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet Balance is Zero',
                        style: TextStyle(
                          color: Color(0xFF2C1D06),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Recharge your wallet to keep receiving ride requests.',
                        style: TextStyle(
                          color: Color(0xFF6B531C),
                          fontSize: 11.5,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Balance indicator chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0CB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE5C16C),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD32F2F),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Current balance: ₹${balance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF8A1C0E),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Bottom Section: Decorative Divider + Modern Traditional Recharge CTA Button
            Container(
              height: 1,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37).withValues(alpha: 0.05),
                    const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    const Color(0xFFD4AF37).withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF8A6411),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Fast & Secure Recharge',
                        style: TextStyle(
                          color: Color(0xFF705616),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Traditional Royal Metallic Action Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onRecharge,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8A1C0E), Color(0xFFB82614)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE5B54F),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF8A1C0E).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.add_card_rounded,
                            color: Color(0xFFFFD76A),
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Recharge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that draws traditional Indian Toran / Jharokha arch corner motifs
class _TraditionalArchPainter extends CustomPainter {
  final Color color;

  const _TraditionalArchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // --- Top-Right Corner Motif ---
    final trPath = Path();
    trPath.moveTo(size.width - 45, 0);
    trPath.quadraticBezierTo(size.width - 25, 0, size.width - 25, 20);
    trPath.quadraticBezierTo(size.width - 25, 40, size.width, 40);
    canvas.drawPath(trPath, paint);

    final trPathInner = Path();
    trPathInner.moveTo(size.width - 30, 0);
    trPathInner.quadraticBezierTo(size.width - 15, 0, size.width - 15, 15);
    trPathInner.quadraticBezierTo(size.width - 15, 28, size.width, 28);
    canvas.drawPath(trPathInner, paint);

    // Decorative Lotus/Accent Petals in Top-Right
    canvas.drawCircle(Offset(size.width - 15, 15), 2.2, fillPaint);
    canvas.drawCircle(Offset(size.width - 25, 6), 1.5, fillPaint);
    canvas.drawCircle(Offset(size.width - 6, 25), 1.5, fillPaint);

    // --- Bottom-Left Corner Motif ---
    final blPath = Path();
    blPath.moveTo(0, size.height - 40);
    blPath.quadraticBezierTo(25, size.height - 40, 25, size.height - 20);
    blPath.quadraticBezierTo(25, size.height, 45, size.height);
    canvas.drawPath(blPath, paint);

    final blPathInner = Path();
    blPathInner.moveTo(0, size.height - 28);
    blPathInner.quadraticBezierTo(15, size.height - 28, 15, size.height - 15);
    blPathInner.quadraticBezierTo(15, size.height, 30, size.height);
    canvas.drawPath(blPathInner, paint);

    // Decorative Accent Dots in Bottom-Left
    canvas.drawCircle(Offset(15, size.height - 15), 2.2, fillPaint);
    canvas.drawCircle(Offset(6, size.height - 25), 1.5, fillPaint);
    canvas.drawCircle(Offset(25, size.height - 6), 1.5, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _TraditionalArchPainter oldDelegate) =>
      oldDelegate.color != color;
}
