import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/controllers/RideController.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/views/components/MapViewWidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideView extends GetView<RideController> {
  const RideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _DummyMap(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopButton(Icons.arrow_back_rounded, () => Get.back()),
                  _buildTopButton(Icons.navigation_rounded, () {}),
                ],
              ),
            ),
          ),
          _buildRideDetailsSheet(),
        ],
      ),
    );
  }

  Widget _buildTopButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildRideDetailsSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.45,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
              )
            ],
          ),
          child: Obx(() {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                _buildDragHandle(),
                const SizedBox(height: 16),
                _buildRiderInfo(),
                const Divider(height: 24),
                _buildRouteTimeline(),
                const Divider(height: 24),
                switch (controller.rideStatus.value) {
                  RideStatus.awaiting_otp => _buildOtpSection(),
                  RideStatus.in_progress => _buildInProgressSection(),
                  RideStatus.completed => _buildCompletedSection(),
                },
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildRiderInfo() {
    final b = controller.booking.value;
    final name = b?.driverName ?? 'John Wick';

    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.inputFill,
          child: Icon(Icons.person_outline_rounded, size: 32, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.call, color: AppColors.primaryDark, size: 28),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.message_rounded, color: AppColors.primaryDark, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildRouteTimeline() {
    final b = controller.booking.value;
    final pickup = b?.pickupAddress ?? 'MG Road Metro Station';
    final drop = b?.dropAddress ?? 'Indiranagar 12th Main';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.circle, color: AppColors.primaryDark, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PICKUP ADDRESS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pickup,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DROP-OFF ADDRESS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    drop,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpSection() {
    final expectedOtpLength = controller.booking.value?.startOtp?.length ?? 6;
    final hintDashes = '-' * expectedOtpLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Enter OTP from rider to start the trip', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        TextField(
          controller: controller.otpController,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            letterSpacing: expectedOtpLength == 6 ? 8 : 12,
          ),
          keyboardType: TextInputType.number,
          maxLength: expectedOtpLength,
          decoration: InputDecoration(
            counterText: '',
            hintText: hintDashes,
            hintStyle: TextStyle(
              color: AppColors.border, 
              letterSpacing: expectedOtpLength == 6 ? 8 : 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.login_rounded),
          label: const Text('Verify & Start Ride'),
          onPressed: controller.verifyOtpAndStartRide,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Enter End OTP from rider to complete the trip', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        TextField(
          controller: controller.endOtpController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 8,
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: const TextStyle(
              color: AppColors.border, 
              letterSpacing: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Complete Ride'),
          onPressed: controller.completeRide,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedSection() {
    final booking = controller.booking.value;
    final fare = booking?.finalAmount ?? booking?.estimatedAmount ?? 0.0;
    return Column(
      children: [
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
        const SizedBox(height: 16),
        const Text('Ride Completed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Total Fare: ₹${fare.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Get.offAllNamed(RouteNames.home),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
          child: const Text('Back to Home'),
        ),
      ],
    );
  }
}

class _DummyMap extends GetView<RideController> {
  const _DummyMap();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final initialTarget = controller.currentDriverPosition.value ?? const LatLng(12.9715987, 77.5945627);
      return MapViewWidget(
        pickupLocation: initialTarget,
        markers: controller.markers,
        polylines: controller.polylines,
        onMapCreated: controller.onMapCreated,
        compassEnabled: true,
        myLocationButtonEnabled: false,
      );
    });
  }
}
