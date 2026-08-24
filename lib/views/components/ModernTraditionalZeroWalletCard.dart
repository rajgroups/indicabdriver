import 'package:flutter/material.dart';

// ─── Rapido-style palette ────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A1A2E);
const _kGreen  = Color(0xFF00C853);
const _kBg     = Color(0xFFF5F6FA);
const _kBorder = Color(0xFFEEEFF3);
const _kMuted  = Color(0xFFB0B3C1);
const _kRed    = Color(0xFFE53935);

/// A premium Modern Traditional Indian aesthetic card displayed on the Home Screen
/// when the driver's wallet balance reaches zero (₹0.00). Updated to Navy & Green theme.
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
        color: _kNavy,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _kNavy.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _kNavy.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _kRed.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        color: _kRed,
                        size: 11,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'ACCOUNT ALERT • ACTION REQUIRED',
                        style: TextStyle(
                          color: _kRed,
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
                      color: _kNavy,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Zero Balance',
                      style: TextStyle(
                        color: _kNavy,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _kNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _kNavy.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: _kNavy,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet Balance is Zero',
                        style: TextStyle(
                          color: _kNavy,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Recharge your wallet to keep receiving ride requests.',
                        style: TextStyle(
                          color: _kMuted,
                          fontSize: 11.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
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
                          color: _kBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _kBorder,
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
                                color: _kRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Current balance: ₹${balance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: _kRed,
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

            // Bottom Section
            Container(
              height: 1,
              width: double.infinity,
              color: _kBorder,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: _kNavy,
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Fast & Secure Recharge',
                        style: TextStyle(
                          color: _kMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
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
                        color: _kNavy,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _kNavy.withValues(alpha: 0.25),
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
                            color: Colors.white,
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
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.10)
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
