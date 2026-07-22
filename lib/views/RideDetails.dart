import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/models/booking_response.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/layout/app.dart';
import 'package:indicab_driver/models/ride_history_item.dart';
import 'InvoiceScreen.dart';


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
        backgroundColor: AppColors.authBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ride details unavailable'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: Get.back,
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
    final paymentMethod = bookingData?.bookingMode ?? rideItem?.paymentMethod ?? 'UPI / Cash';

    return AppScreen(
      backgroundColor: AppColors.authBackground,
      scrollable: true,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ride Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Fare breakdown, route and trip summary',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        color: AppColors.primaryDark,
                        size: 28,
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
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF2A9D8F),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Trip completed successfully. Receipt available for download.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Trip route',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _RouteTile(pickup: pickup, drop: drop),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _InfoSection(
            title: 'Ride summary',
            children: [
              _InfoRow(
                label: 'Status',
                value: status.toUpperCase(),
                valueColor: const Color(0xFF2A9D8F),
              ),
              _InfoRow(
                label: 'Rating',
                value: '4.9 / 5',
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoSection(
            title: 'Driver and vehicle',
            children: [
              _InfoRow(label: 'Driver', value: driverName),
              _InfoRow(label: 'Vehicle no.', value: vehicleNumber),
              _InfoRow(label: 'Booking ID', value: bookingId),
              _InfoRow(label: 'Payment', value: paymentMethod),
            ],
          ),
          const SizedBox(height: 18),
          _InfoSection(
            title: 'Fare breakdown',
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
                emphasize: true,
              ),
            ],
          ),
          const SizedBox(height: 22),
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
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.offAllNamed(RouteNames.home);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Book Again',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({required this.pickup, required this.drop});

  final String pickup;
  final String drop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A9D8F),
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 42, color: AppColors.border),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFE76F51),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  drop,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasize ? 15 : 13,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
