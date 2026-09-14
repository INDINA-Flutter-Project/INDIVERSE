import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';

class DeveloperEndScreen extends StatelessWidget {
  const DeveloperEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Image.asset('assets/images/indiverse_mark.png', width: 92),
              const SizedBox(height: 28),
              const Text(
                'Together for a\nBigger Tomorrow.',
                textAlign: TextAlign.center,
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: 18),
              Container(
                width: 74,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Spacer(),
              const Icon(Icons.temple_hindu_rounded, color: Colors.white24, size: 120),
              const SizedBox(height: 18),
              const Text('Saudi Games Hub', style: AppTextStyles.bodyMuted),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
