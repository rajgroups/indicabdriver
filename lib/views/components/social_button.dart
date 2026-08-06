import 'package:flutter/material.dart';
import 'package:indicab_driver/constants/Colors.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isGoogle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isGoogle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.border,
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          backgroundColor: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/300/300221.png',
                height: 22,
                width: 22,
                errorBuilder: (context, error, stackTrace) => Icon(icon, size: 22),
              )
            else
              Icon(icon, size: 24, color: AppColors.textPrimary),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
