import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';

class DeveloperStatCard extends StatelessWidget {
  const DeveloperStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.bodyMuted)),
              Icon(icon, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.pageTitle.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
