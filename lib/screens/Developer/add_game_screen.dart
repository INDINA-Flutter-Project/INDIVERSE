import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import 'game_detail_screen.dart';

class AddGameScreen extends StatelessWidget {
  const AddGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Game')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                SizedBox(height: 8),
                Text('Upload Cover Image', style: AppTextStyles.body),
                Text('PNG, JPG (Max 5MB)', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _DeveloperTextField(label: 'Game Title', hint: 'Enter game title'),
          const SizedBox(height: 14),
          const _DeveloperTextField(
            label: 'Description',
            hint: 'Tell us about your game...',
            maxLines: 4,
          ),
          const SizedBox(height: 14),
          const _DeveloperDropdown(label: 'Genre', value: 'Select genre'),
          const SizedBox(height: 14),
          const _DeveloperDropdown(label: 'Platform', value: 'Select platform'),
          const SizedBox(height: 14),
          const _DeveloperDropdown(label: 'Status', value: 'Select status'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DeveloperGameDetailScreen()),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text('Publish Game'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperTextField extends StatelessWidget {
  const _DeveloperTextField({
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

class _DeveloperDropdown extends StatelessWidget {
  const _DeveloperDropdown({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        children: [
          Expanded(child: Text(value, style: AppTextStyles.bodyMuted)),
          const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }
}
