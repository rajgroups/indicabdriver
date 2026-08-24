import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/controllers/RideController.dart';
import 'package:indicab_driver/routes/names.dart';
import 'package:indicab_driver/views/components/MapViewWidget.dart';
import 'package:indicab_driver/views/components/RideInfoBar.dart';
import 'package:indicab_driver/views/components/DestinationReachedSheet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ─── Rapido-style palette ────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A1A2E);
const _kGreen  = Color(0xFF00C853);
const _kRed    = Color(0xFFE53935);
const _kBg     = Color(0xFFF5F6FA);
const _kBorder = Color(0xFFEEEFF3);
const _kMuted  = Color(0xFFB0B3C1);

class RideView extends GetView<RideController> {
  const RideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Obx(() {
        return Stack(
          children: [
            // Full-screen map
            const _RideMap(),

            // Top buttons (back + navigate)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircleButton(Icons.arrow_back_ios_new_rounded, () => Get.back(), iconSize: 18),
                    if (_shouldShowNavigateButton())
                      _buildCircleButton(
                        Icons.navigation_rounded,
                        controller.launchGoogleNavigation,
                        color: _kNavy,
                        iconColor: Colors.white,
                      ),
                  ],
                ),
              ),
            ),

            // ETA / Distance info bar
            Positioned(
              bottom: _getInfoBarBottomPosition(),
              left: 0,
              right: 0,
              child: const RideInfoBar(),
            ),

            // Reached Pickup animation overlay
            if (controller.showReachedAnimation.value)
              _buildReachedAnimationOverlay(),

            // Destination Reached auto sheet
            if (controller.showDestinationSheet.value)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: const DestinationReachedSheet(),
              ),

            // Main bottom sheet
            if (!controller.showDestinationSheet.value)
              _buildRideDetailsSheet(),
          ],
        );
      }),
    );
  }

  bool _shouldShowNavigateButton() {
    final status = controller.rideStatus.value;
    if (status == RideStatus.accepted) return true;
    if (status == RideStatus.in_progress && controller.isTransportMode) return true;
    return false;
  }

  double _getInfoBarBottomPosition() {
    final status = controller.rideStatus.value;
    if (status == RideStatus.completed) return 0;
    return MediaQuery.of(Get.context!).size.height * 0.45 + 8;
  }

  Widget _buildCircleButton(
    IconData icon,
    VoidCallback onPressed, {
    Color color = Colors.white,
    Color iconColor = _kNavy,
    double iconSize = 24,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: iconSize),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildReachedAnimationOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: _kGreen,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reached Pickup!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Waiting for passenger...',
                style: TextStyle(
                  fontSize: 14,
                  color: _kMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideDetailsSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.42,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: _kNavy.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
            border: const Border(top: BorderSide(color: _kBorder)),
          ),
          child: Obx(() {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                _buildDragHandle(),
                const SizedBox(height: 16),
                _buildPassengerInfo(),
                const Divider(height: 24, color: _kBorder),
                _buildRouteTimeline(),
                const Divider(height: 24, color: _kBorder),
                switch (controller.rideStatus.value) {
                  RideStatus.accepted => _buildAcceptedSection(),
                  RideStatus.reached_pickup => _buildReachedPickupSection(),
                  RideStatus.in_progress => _buildInProgressSection(),
                  RideStatus.destination_reached => _buildDestinationReachedSection(),
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
          color: _kBorder,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPassengerInfo() {
    final b = controller.booking.value;
    final name = b?.passengerName ?? b?.driverName ?? 'Passenger';
    final category = b?.categoryName;

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: _kBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_outline_rounded, size: 32, color: _kNavy),
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
                  fontWeight: FontWeight.w800,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _kGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  const Text('4.9', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _kNavy)),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.call, color: _kGreen, size: 28),
          onPressed: controller.callPassenger,
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.message_rounded, color: _kNavy, size: 28),
          onPressed: () {
            Get.snackbar('Chat', 'Chat feature coming soon.');
          },
        ),
      ],
    );
  }

  Widget _buildRouteTimeline() {
    final b = controller.booking.value;
    final pickup = b?.pickupAddress ?? 'Pickup Location';
    final drop = b?.dropAddress;
    final isWork = controller.isWorkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pickup
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.circle, color: _kGreen, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWork ? 'WORK LOCATION' : 'PICKUP ADDRESS',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _kMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pickup,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Drop-off
        if (!isWork && drop != null) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, color: _kRed, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DROP-OFF ADDRESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _kMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      drop,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        // Duration
        if (isWork && b?.durationHours != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: _kNavy, size: 16),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SERVICE DURATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _kMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${b!.durationHours!.toStringAsFixed(1)} hours',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Phase 1: Accepted (Heading to Pickup)
  Widget _buildAcceptedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _kNavy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kNavy.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_car_rounded, color: _kNavy, size: 20),
              const SizedBox(width: 8),
              Text(
                controller.isWorkMode ? 'Heading to work location' : 'Heading to pickup',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Obx(() => ElevatedButton.icon(
          icon: controller.isReachingPickup.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.location_on_rounded),
          label: Text(
            controller.isReachingPickup.value
                ? 'Updating...'
                : (controller.isWorkMode ? 'Reached Location' : 'Reached Pickup'),
          ),
          onPressed: controller.isReachingPickup.value ? null : controller.reachedPickup,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )),
      ],
    );
  }

  // Phase 2: Reached Pickup (Waiting + OTP)
  Widget _buildReachedPickupSection() {
    final expectedOtpLength = controller.booking.value?.startOtp?.length ?? 6;
    final hintDashes = '-' * expectedOtpLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _kGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kGreen.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: _kGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.isWorkMode
                      ? 'At work location — waiting for customer'
                      : 'At pickup — waiting for passenger',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          controller.isWorkMode
              ? 'Enter OTP from customer to start work'
              : 'Enter OTP from passenger to start ride',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _kMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.otpController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: _kNavy,
          ),
          keyboardType: TextInputType.number,
          maxLength: expectedOtpLength,
          decoration: InputDecoration(
            counterText: '',
            hintText: hintDashes,
            hintStyle: TextStyle(
              color: _kBorder,
              letterSpacing: expectedOtpLength == 6 ? 8 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kNavy, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() => ElevatedButton.icon(
          icon: controller.isStartingRide.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.play_arrow_rounded),
          label: Text(
            controller.isStartingRide.value
                ? 'Starting...'
                : (controller.isWorkMode ? 'Start Work' : 'Start Ride'),
          ),
          onPressed: controller.isStartingRide.value ? null : controller.verifyOtpAndStartRide,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kNavy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )),
      ],
    );
  }

  // Phase 3: In Progress
  Widget _buildInProgressSection() {
    if (controller.isWorkMode) {
      return _buildWorkInProgressSection();
    } else {
      return _buildTransportInProgressSection();
    }
  }

  Widget _buildTransportInProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.directions_car_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Ride in progress — heading to drop-off',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter End OTP from passenger to complete',
          textAlign: TextAlign.center,
          style: TextStyle(color: _kMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.endOtpController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: _kNavy,
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: const TextStyle(color: _kBorder, letterSpacing: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kNavy, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() => ElevatedButton.icon(
          icon: controller.isCompletingRide.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle_outline_rounded),
          label: Text(controller.isCompletingRide.value ? 'Completing...' : 'Complete Ride'),
          onPressed: controller.isCompletingRide.value ? null : controller.completeRide,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )),
      ],
    );
  }

  Widget _buildWorkInProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.construction_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Work in progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (controller.booking.value?.durationHours != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: _kNavy, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booked Duration',
                      style: TextStyle(fontSize: 12, color: _kMuted, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${controller.booking.value!.durationHours!.toStringAsFixed(1)} hours',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _kNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        const Text(
          'Enter End OTP from customer to complete work',
          textAlign: TextAlign.center,
          style: TextStyle(color: _kMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.endOtpController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: _kNavy,
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: const TextStyle(color: _kBorder, letterSpacing: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kNavy, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() => ElevatedButton.icon(
          icon: controller.isCompletingRide.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle_outline_rounded),
          label: Text(controller.isCompletingRide.value ? 'Completing...' : 'Complete Work'),
          onPressed: controller.isCompletingRide.value ? null : controller.completeRide,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )),
      ],
    );
  }

  // Phase 4: Destination Reached
  Widget _buildDestinationReachedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _kGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kGreen.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.place_rounded, color: _kGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'You\'ve arrived at the destination',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter End OTP from passenger to complete',
          textAlign: TextAlign.center,
          style: TextStyle(color: _kMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.endOtpController,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8, color: _kNavy),
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: const TextStyle(color: _kBorder, letterSpacing: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kNavy, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() => ElevatedButton.icon(
          icon: controller.isCompletingRide.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle_outline_rounded),
          label: Text(controller.isCompletingRide.value ? 'Completing...' : 'Complete Ride'),
          onPressed: controller.isCompletingRide.value ? null : controller.completeRide,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )),
      ],
    );
  }

  // Phase 5: Completed
  Widget _buildCompletedSection() {
    final booking = controller.booking.value;
    final fare = booking?.finalAmount ?? booking?.estimatedAmount ?? 0.0;
    final isWork = controller.isWorkMode;

    return Column(
      children: [
        const Icon(Icons.check_circle_rounded, color: _kGreen, size: 60),
        const SizedBox(height: 16),
        Text(
          isWork ? 'Work Completed!' : 'Ride Completed!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _kNavy),
        ),
        const SizedBox(height: 8),
        Text(
          'Total Fare: ₹${fare.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, color: _kGreen, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Get.offAllNamed(RouteNames.home),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kNavy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Back to Home'),
        ),
      ],
    );
  }
}

class _RideMap extends GetView<RideController> {
  const _RideMap();

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
