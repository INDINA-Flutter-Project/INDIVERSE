import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/text_styles.dart';

class GlassAction extends StatelessWidget {
  const GlassAction({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    this.borderRadius = 999,
  }) : assert(label != null || child != null);

  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.glassBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.095),
                AppColors.glassFill,
                AppColors.primary.withValues(alpha: 0.10),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.16),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0, 0.38, 1],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child:
                    child ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: AppColors.textPrimary),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label!,
                          style: AppTextStyles.interface.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
