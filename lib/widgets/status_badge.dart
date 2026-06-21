import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final String normalized = status.toLowerCase();

    Color backgroundColor;
    Color textColor;
    String label;

    if (normalized == 'approved' || normalized == 'successful') {
      backgroundColor = AppColors.lightGreen;
      textColor = AppColors.successGreen;
      label = 'Successful';
    } else if (normalized == 'pending') {
      backgroundColor = AppColors.lightOrange;
      textColor = AppColors.pendingOrange;
      label = 'Pending';
    } else {
      backgroundColor = AppColors.lightBlue;
      textColor = AppColors.primaryBlue;
      label = 'Not Applied';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}