import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicab_driver/constants/Colors.dart';
import 'package:indicab_driver/controllers/RideController.dart';

/// Floating bar showing ETA, distance, and estimated arrival time.
class RideInfoBar extends GetView<RideController> {
  const RideInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final distance = controller.remainingDistance.value;
      final duration = controller.remainingDuration.value;
      final arrival = controller.estimatedArrival.value;

      if (distance.isEmpty && duration.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (duration.isNotEmpty)
              _InfoItem(
                icon: Icons.access_time_rounded,
                label: 'ETA',
                value: duration,
                color: AppColors.primaryDark,
              ),
            if (duration.isNotEmpty && distance.isNotEmpty)
              Container(
                width: 1,
                height: 36,
                color: AppColors.borderSoft,
              ),
            if (distance.isNotEmpty)
              _InfoItem(
                icon: Icons.straighten_rounded,
                label: 'Distance',
                value: distance,
                color: const Color(0xFF1A8B4C),
              ),
            if (arrival.isNotEmpty) ...[
              Container(
                width: 1,
                height: 36,
                color: AppColors.borderSoft,
              ),
              _InfoItem(
                icon: Icons.schedule_rounded,
                label: 'Arrival',
                value: arrival,
                color: Colors.blue,
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
