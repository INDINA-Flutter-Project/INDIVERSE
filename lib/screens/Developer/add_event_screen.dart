import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/game.dart';
import '../../models/game_event.dart';
import '../../service/game_event_service.dart';

/// Creates or edits an event for [game]. The game is fixed by whichever
/// Developer Game Details screen this was opened from — there is no game
/// picker here, and editing never moves an event to another game.
class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key, required this.game, this.existingEvent});

  final Game game;
  final GameEvent? existingEvent;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late final _titleController = TextEditingController(
    text: widget.existingEvent?.title ?? '',
  );
  late final _locationController = TextEditingController(
    text: widget.existingEvent?.location ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.existingEvent?.description ?? '',
  );
  late DateTime? _selectedDate = widget.existingEvent?.eventDate;
  late TimeOfDay? _selectedTime = _parseTime(widget.existingEvent?.eventTime);

  bool _submitting = false;
  String? _error;

  bool get _isEditing => widget.existingEvent != null;

  static TimeOfDay? _parseTime(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (_submitting) return;

    final title = _titleController.text.trim();
    final date = _selectedDate;

    if (title.isEmpty) {
      setState(() => _error = 'Event title is required.');
      return;
    }
    if (date == null) {
      setState(() => _error = 'Event date is required.');
      return;
    }

    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();
    final time = _selectedTime;
    final eventTime = time == null
        ? null
        : '${time.hour.toString().padLeft(2, '0')}:'
              '${time.minute.toString().padLeft(2, '0')}:00';

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final existingEvent = widget.existingEvent;
      final GameEvent saved;
      if (existingEvent != null) {
        saved = await GameEventService().updateEvent(
          GameEvent(
            id: existingEvent.id,
            gameId: existingEvent.gameId,
            title: title,
            eventDate: date,
            eventTime: eventTime,
            location: location.isEmpty ? null : location,
            description: description.isEmpty ? null : description,
          ),
        );
      } else {
        saved = await GameEventService().addEvent(
          gameId: widget.game.id,
          title: title,
          eventDate: date,
          eventTime: eventTime,
          location: location.isEmpty ? null : location,
          description: description.isEmpty ? null : description,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, saved);
    } catch (e, st) {
      debugPrint('${_isEditing ? 'updateEvent' : 'addEvent'} failed: $e\n$st');
      if (!mounted) return;
      setState(
        () => _error =
            'Could not ${_isEditing ? 'save changes' : 'add event'}: $e',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Event' : 'Add Event')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          _EventField(
            label: 'Event Title',
            hint: 'Enter event title',
            controller: _titleController,
          ),
          const SizedBox(height: 14),
          _EventPickerField(
            label: 'Date',
            value: _selectedDate == null
                ? null
                : GameEvent.formatDate(_selectedDate!),
            hint: 'Select date',
            icon: Icons.calendar_today_outlined,
            onTap: _pickDate,
          ),
          const SizedBox(height: 14),
          _EventPickerField(
            label: 'Time',
            value: _selectedTime?.format(context),
            hint: 'Select time',
            icon: Icons.access_time_rounded,
            onTap: _pickTime,
          ),
          const SizedBox(height: 14),
          _EventField(
            label: 'Location',
            hint: 'Enter location',
            controller: _locationController,
          ),
          const SizedBox(height: 14),
          _EventField(
            label: 'Description',
            hint: 'Tell us about the event...',
            controller: _descriptionController,
            maxLines: 4,
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Save Event'),
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
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

/// A read-only, tappable field that opens a date/time picker — styled like
/// [_EventField] so the form stays visually consistent.
class _EventPickerField extends StatelessWidget {
  const _EventPickerField({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: Icon(icon)),
        child: Text(
          value ?? hint,
          style: value == null
              ? AppTextStyles.bodyMuted
              : AppTextStyles.body,
        ),
      ),
    );
  }
}
