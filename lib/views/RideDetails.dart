import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/layout/app.dart';
import 'package:indicab_driver/models/ride_history_item.dart';
import 'InvoiceScreen.dart';

// ─── Rapido-style palette ────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A1A2E);
const _kGreen  = Color(0xFF00C853);
const _kRed    = Color(0xFFE53935);
const _kBg     = Color(0xFFF5F6FA);
const _kBorder = Color(0xFFEEEFF3);
const _kMuted  = Color(0xFFB0B3C1);

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArg = Get.arguments;

    BookingDataModel? bookingData;
    RideHistoryItem? rideItem;

    if (rawArg is BookingDataModel) {
      bookingData = rawArg;
    } else if (rawArg is RideHistoryItem) {
      rideItem = rawArg;
    }

    if (bookingData == null && rideItem == null) {
      return AppScreen(
        backgroundColor: _kBg,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: _kMuted),
              const SizedBox(height: 14),
              const Text(
                'Ride details unavailable',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: Get.back,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back to History'),
              ),
            ],
          ),
        ),
      );
    }

    final category = bookingData?.categoryName ?? rideItem?.type ?? 'Ride';
    final amountText = bookingData != null
        ? (bookingData.estimatedAmount != null
            ? '₹${bookingData.estimatedAmount!.toStringAsFixed(2)}'
            : '₹0.00')
        : (rideItem?.amountLabel ?? '₹0.00');
    final amountValue = bookingData?.estimatedAmount ?? rideItem?.amountValue ?? 0.0;
    final dateLabel = bookingData?.scheduledAt ?? rideItem?.dateLabel ?? 'Recent';
    final pickup = bookingData?.pickupAddress ?? rideItem?.pickup ?? 'Pickup Address';
    final drop = bookingData?.dropAddress ?? rideItem?.drop ?? 'Drop Address';
    final status = bookingData?.status ?? rideItem?.status ?? 'Completed';
    final driverName = bookingData?.driverName ?? rideItem?.driverName ?? 'Assigned Driver';
    final vehicleNumber = bookingData?.vehicleNumber ?? rideItem?.vehicleNumber ?? 'Vehicle N/A';
    final bookingId = bookingData?.bookingNo ?? rideItem?.bookingId ?? 'N/A';
    final bookingModeLabel = (bookingData?.bookingMode ?? 'instant') == 'scheduled' ? 'Scheduled Ride' : 'Instant Ride';
    final paymentMethod = bookingData?.paymentMethod ?? rideItem?.paymentMethod ?? 'Cash';
    final scheduledAtText = bookingData?.scheduledAt;

    return AppScreen(
      backgroundColor: _kBg,
      scrollable: true,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Rapido-style top bar ──────────────────────────────────────
          _RapidoBar(
            title: 'Ride Details',
            subtitle: 'Fare breakdown & trip summary',
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero card: category + amount ─────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _kNavy,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _kNavy.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.directions_car_filled_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        amountText,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _kGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Status pill
                _StatusPill(status: status),
                const SizedBox(height: 18),

                // ── Route section ─────────────────────────────────────
                _CardSection(
                  title: 'Trip Route',
                  child: _RouteRail(pickup: pickup, drop: drop),
                ),
                const SizedBox(height: 14),

                // ── Ride summary ──────────────────────────────────────
                _CardSection(
                  title: 'Ride Summary',
                  child: Column(
                    children: [
                      _InfoRow(label: 'Status', value: status.toUpperCase(), accent: _kGreen),
                      _InfoRow(label: 'Booking Type', value: bookingModeLabel),
                      if (scheduledAtText != null && scheduledAtText.isNotEmpty)
                        _InfoRow(label: 'Scheduled For', value: scheduledAtText),
                      const _InfoRow(label: 'Rating', value: '4.9 / 5 ⭐'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Driver & vehicle ──────────────────────────────────
                _CardSection(
                  title: 'Driver & Vehicle',
                  child: Column(
                    children: [
                      _InfoRow(label: 'Driver', value: driverName),
                      _InfoRow(label: 'Vehicle no.', value: vehicleNumber),
                      _InfoRow(label: 'Booking ID', value: bookingId),
                      _InfoRow(label: 'Payment', value: paymentMethod.toUpperCase()),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Fare breakdown ────────────────────────────────────
                _CardSection(
                  title: 'Fare Breakdown',
                  child: Column(
                    children: [
                      _InfoRow(
                        label: 'Base fare',
                        value: '₹${(amountValue * 0.70).toStringAsFixed(0)}',
                      ),
                      _InfoRow(
                        label: 'Taxes and fees',
                        value: '₹${(amountValue * 0.30).toStringAsFixed(0)}',
                      ),
                      _InfoRow(
                        label: 'Total paid',
                        value: amountText,
                        accent: _kGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Action buttons ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final item = rideItem ?? (bookingData != null ? RideHistoryItem.fromBookingData(bookingData) : null);
                          if (item != null) {
                            Get.to(() => InvoiceScreen(ride: item));
                          } else {
                            Get.snackbar('Invoice', 'Invoice details unavailable.');
                          }
                        },
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Invoice'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kNavy,
                          side: const BorderSide(color: _kBorder),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.offAllNamed(RouteNames.home),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          'Book Again',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
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

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _RapidoBar extends StatelessWidget {
  const _RapidoBar({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
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
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: _kNavy),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kNavy,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isDone = status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'success';
    final pillBg = isDone ? _kGreen.withValues(alpha: 0.12) : _kRed.withValues(alpha: 0.12);
    final textCol = isDone ? _kGreen : _kRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textCol.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: textCol,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDone
                  ? 'Trip completed successfully. Receipt available for download.'
                  : 'Trip Status: ${status.toUpperCase()}',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: textCol,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kNavy,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _RouteRail extends StatelessWidget {
  const _RouteRail({required this.pickup, required this.drop});
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
            Container(width: 2, height: 36, color: _kBorder),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: _kRed,
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
              Text(
                pickup,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                drop,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: _kMuted),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent ?? _kNavy,
            ),
          ),
        ],
      ),
    );
  }
}
