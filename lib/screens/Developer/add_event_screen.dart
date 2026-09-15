import 'package:flutter/material.dart';

import '../../core/constants/text_styles.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  String type = 'event';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          const _EventField(label: 'Event Title', hint: 'Enter event title'),
          const SizedBox(height: 14),
          const _EventDropdown(label: 'Related Game', value: 'Select a game'),
          const SizedBox(height: 14),
          const Text('Type', style: AppTextStyles.body),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'event', label: Text('Event')),
              ButtonSegment(value: 'playtest', label: Text('Playtest')),
            ],
            selected: {type},
            onSelectionChanged: (value) => setState(() => type = value.first),
          ),
          const SizedBox(height: 14),
          const _EventField(
            label: 'Date',
            hint: 'Select date',
            suffixIcon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 14),
          const _EventField(
            label: 'Time',
            hint: 'Select time',
            suffixIcon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 14),
          const _EventField(label: 'Location', hint: 'Enter location'),
          const SizedBox(height: 14),
          const _EventField(
            label: 'Description',
            hint: 'Tell us about the event...',
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text('Save Event'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventField extends StatelessWidget {
  const _EventField({
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final int maxLines;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
      ),
    );
  }
}

class _EventDropdown extends StatelessWidget {
  const _EventDropdown({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        children: [
          Expanded(child: Text(value, style: AppTextStyles.body)),
          const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }
}
