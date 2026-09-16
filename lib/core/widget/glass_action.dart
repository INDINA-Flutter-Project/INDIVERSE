import 'dart:ui';

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
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.105),
                    Colors.white.withValues(alpha: 0.04),
                    AppColors.primary.withValues(alpha: 0.035),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
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
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.14),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.48],
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
                              Icon(
                                icon,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
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
        ),
      ),
    );
  }
}
