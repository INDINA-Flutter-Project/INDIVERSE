import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';

class DeveloperGameTile extends StatelessWidget {
  const DeveloperGameTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.accentColor,
    required this.icon,
    this.imageUrl,
    this.showMenu = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String status;
  final Color accentColor;
  final IconData icon;
  final String? imageUrl;
  final bool showMenu;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            (imageUrl == null || imageUrl!.isEmpty)
                ? _FallbackThumbnail(accentColor: accentColor, icon: icon)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _FallbackThumbnail(
                            accentColor: accentColor,
                            icon: icon,
                          ),
                    ),
                  ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodyMuted),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(status),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColors.primaryContainer,
                      labelStyle: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onTap,
              icon: Icon(
                showMenu
                    ? Icons.more_vert_rounded
                    : Icons.chevron_right_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackThumbnail extends StatelessWidget {
  const _FallbackThumbnail({required this.accentColor, required this.icon});

  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor, AppColors.surfaceRaised],
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 34),
    );
  }
}
