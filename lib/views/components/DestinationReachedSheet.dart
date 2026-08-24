import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/controllers/RideController.dart';

// ─── Rapido-style palette ────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A1A2E);
const _kGreen  = Color(0xFF00C853);
const _kBorder = Color(0xFFEEEFF3);
const _kMuted  = Color(0xFFB0B3C1);

/// Auto-triggered bottom sheet when driver is within 30m of destination.
class DestinationReachedSheet extends GetView<RideController> {
  const DestinationReachedSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Arrived icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.place_rounded,
              color: _kGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Destination Reached',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'ve arrived at the drop-off location',
            style: TextStyle(
              fontSize: 14,
              color: _kMuted,
            ),
          ),
          const SizedBox(height: 24),

          // End OTP
          const Text(
            'Enter End OTP from passenger',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kMuted, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
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
              hintStyle: const TextStyle(
                color: _kBorder,
                letterSpacing: 8,
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

          // Buttons
          Obx(() => ElevatedButton.icon(
            icon: controller.isCompletingRide.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              controller.isCompletingRide.value ? 'Completing...' : 'Complete Ride',
            ),
            onPressed: controller.isCompletingRide.value ? null : controller.completeRide,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )),
          const SizedBox(height: 12),
          TextButton(
            onPressed: controller.dismissDestinationSheet,
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
const _kRed = Color(0xFFE53935);
