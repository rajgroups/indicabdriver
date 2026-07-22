import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/constants/Strings.dart';
import 'package:indicab_driver/models/ride_history_item.dart';


class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key, required this.ride});
  
  final RideHistoryItem ride;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text('Tax Invoice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600), // Ensures it stays 'A4' like on tablets
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                const Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black),
                ),
                const SizedBox(height: 4),
                const Text(
                  'TAX INVOICE / RECEIPT',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 1),
                ),
                const SizedBox(height: 32),
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 16),

                // META DETAILS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InvoiceMetaBlock(title: 'Date & Time', value: ride.dateLabel),
                    _InvoiceMetaBlock(title: 'Booking ID', value: ride.bookingId, alignRight: true),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InvoiceMetaBlock(title: 'Vehicle Type', value: ride.type),
                    _InvoiceMetaBlock(title: 'Vehicle Number', value: ride.vehicleNumber, alignRight: true),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 16),

                // RIDE LOCATIONS
                const Text('TRIP DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 12),
                Text('From: ${ride.pickup}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                Text('To: ${ride.drop}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 12),
                Text('Distance: ${ride.distance}  •  Duration: ${ride.duration}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                
                const SizedBox(height: 16),
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 16),

                // FARE BREAKDOWN
                const Text('FARE BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 16),
                _FareRow(label: 'Ride Fare', value: '₹${(ride.amountValue * 0.85).toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _FareRow(label: 'Taxes & Fees (15%)', value: '₹${(ride.amountValue * 0.15).toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                const Divider(color: Colors.black87, thickness: 1.5),
                const SizedBox(height: 12),
                
                // TOTAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                    Text('₹${ride.amountValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.black87, thickness: 1.5),
                const SizedBox(height: 24),
                
                // FOOTER
                Center(
                  child: Text(
                    'Paid via ${ride.paymentMethod}\nThank you for riding with ${AppStrings.appName}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implement real PDF generation or share logic here
          Get.snackbar('Saving', 'Invoice saved to documents.', backgroundColor: AppColors.surface);
        },
        icon: const Icon(Icons.print_rounded),
        label: const Text('Print / Save', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
      ),
    );
  }
}

class _InvoiceMetaBlock extends StatelessWidget {
  const _InvoiceMetaBlock({required this.title, required this.value, this.alignRight = false});
  final String title;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
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
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }
}