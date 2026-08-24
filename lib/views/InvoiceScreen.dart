import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Strings.dart';
import 'package:indicab_driver/models/ride_history_item.dart';

// ─── Rapido-style palette ────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A1A2E);
const _kGreen  = Color(0xFF00C853);
const _kBg     = Color(0xFFF5F6FA);
const _kBorder = Color(0xFFEEEFF3);
const _kMuted  = Color(0xFFB0B3C1);

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key, required this.ride});

  final RideHistoryItem ride;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Rapido-style top bar ──────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Material(
                  color: const Color(0xFFF3F4F6),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: Get.back,
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: Icon(Icons.close_rounded,
                            size: 20, color: _kNavy),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tax Invoice',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kNavy,
                  ),
                ),
              ],
            ),
          ),

          // ── Invoice body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Invoice header (navy band) ─────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 24),
                          decoration: const BoxDecoration(
                            color: _kNavy,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                AppStrings.appName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _kGreen.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Text(
                                  'TAX INVOICE / RECEIPT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _kGreen,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Invoice content ────────────────────────
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Meta row: date + booking ID
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetaBlock(
                                      icon: Icons.calendar_today_rounded,
                                      label: 'Date & Time',
                                      value: ride.dateLabel,
                                    ),
                                  ),
                                  Expanded(
                                    child: _MetaBlock(
                                      icon: Icons.confirmation_number_rounded,
                                      label: 'Booking ID',
                                      value: ride.bookingId,
                                      alignRight: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetaBlock(
                                      icon: Icons.directions_car_rounded,
                                      label: 'Vehicle Type',
                                      value: ride.type,
                                    ),
                                  ),
                                  Expanded(
                                    child: _MetaBlock(
                                      icon: Icons.pin_rounded,
                                      label: 'Vehicle Number',
                                      value: ride.vehicleNumber,
                                      alignRight: true,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                              _SectionDivider(label: 'TRIP DETAILS'),
                              const SizedBox(height: 14),

                              // Route rail
                              _InvoiceRouteRail(
                                  pickup: ride.pickup, drop: ride.drop),
                              const SizedBox(height: 10),
                              Text(
                                'Distance: ${ride.distance}  •  Duration: ${ride.duration}',
                                style: const TextStyle(
                                    fontSize: 12, color: _kMuted),
                              ),

                              const SizedBox(height: 20),
                              _SectionDivider(label: 'FARE BREAKDOWN'),
                              const SizedBox(height: 14),

                              _FareRow(
                                label: 'Ride Fare',
                                value: '₹${(ride.amountValue * 0.85).toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 10),
                              _FareRow(
                                label: 'Taxes & Fees (15%)',
                                value: '₹${(ride.amountValue * 0.15).toStringAsFixed(2)}',
                              ),

                              const SizedBox(height: 16),

                              // Total row — navy accent
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: _kNavy,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'TOTAL AMOUNT',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      '₹${ride.amountValue.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: _kGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Footer
                              Center(
                                child: Text(
                                  'Paid via ${ride.paymentMethod}\nThank you for riding with ${AppStrings.appName}.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _kMuted,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.snackbar('Saving', 'Invoice saved to documents.',
              backgroundColor: Colors.white);
        },
        icon: const Icon(Icons.print_rounded),
        label: const Text('Print / Save',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ─── Shared sub-widgets ─────────────────────────────────────────────────────

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.icon,
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: _kMuted),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(fontSize: 11, color: _kMuted)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _kNavy,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _kMuted,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: _kBorder)),
      ],
    );
  }
}

class _InvoiceRouteRail extends StatelessWidget {
  const _InvoiceRouteRail({required this.pickup, required this.drop});
  final String pickup;
  final String drop;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: _kGreen,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 30, color: _kBorder),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickup,
                  style: const TextStyle(fontSize: 14, color: _kNavy)),
              const SizedBox(height: 18),
              Text(drop,
                  style: const TextStyle(fontSize: 14, color: _kNavy)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: _kMuted)),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _kNavy)),
      ],
    );
  }
}