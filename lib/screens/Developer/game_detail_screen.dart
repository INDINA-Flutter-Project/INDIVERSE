import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/game.dart';
import '../../models/game_event.dart';
import '../../service/game_event_service.dart';
import 'add_event_screen.dart';
import 'add_game_screen.dart';

class DeveloperGameDetailScreen extends StatefulWidget {
  const DeveloperGameDetailScreen({super.key, required this.game});

  final Game game;

  @override
  State<DeveloperGameDetailScreen> createState() =>
      _DeveloperGameDetailScreenState();
}

class _DeveloperGameDetailScreenState extends State<DeveloperGameDetailScreen> {
  int selectedTab = 0;
  late Game _game = widget.game;
  bool _wasEdited = false;

  List<GameEvent> _events = const [];
  bool _eventsLoading = true;
  String? _eventsError;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _eventsLoading = true);
    try {
      final events = await GameEventService().getEventsForGame(_game.id);
      if (!mounted) return;
      setState(() {
        _events = events;
        _eventsError = null;
      });
    } catch (e, st) {
      debugPrint('getEventsForGame failed: $e\n$st');
      if (!mounted) return;
      setState(() => _eventsError = 'Could not load events.');
    } finally {
      if (mounted) setState(() => _eventsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    final pages = [
      _AboutTab(game: game),
      _EventsTab(
        events: _events,
        loading: _eventsLoading,
        error: _eventsError,
        onAddEvent: _openAddEvent,
        onEditEvent: _openEditEvent,
        onViewEvent: _openViewEvent,
        onRetry: _loadEvents,
      ),
      const _LinksTab(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _wasEdited);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(game.name)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            (game.coverImage == null || game.coverImage!.isEmpty)
                ? const _FallbackHeader()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      game.coverImage!,
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _FallbackHeader(),
                    ),
                  ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(game.name, style: AppTextStyles.pageTitle),
                ),
                Chip(
                  label: Text(game.displayStatus),
                  backgroundColor: AppColors.primary,
                  labelStyle: AppTextStyles.label.copyWith(color: Colors.black),
                ),
              ],
            ),
            Text(
              'by ${game.developer ?? 'Unknown developer'}',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 12),
            if (game.genres.isNotEmpty)
              Wrap(
                spacing: 8,
                children: [
                  for (final genre in game.genres) Chip(label: Text(genre)),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              game.description ?? 'No description provided.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Play on Steam'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openEditGame,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Game'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('About')),
                ButtonSegment(value: 1, label: Text('Events')),
                ButtonSegment(value: 2, label: Text('Links')),
              ],
              selected: {selectedTab},
              onSelectionChanged: (value) =>
                  setState(() => selectedTab = value.first),
            ),
            const SizedBox(height: 18),
            pages[selectedTab],
          ],
        ),
      ),
    );
  }

  Future<void> _openAddEvent() async {
    final created = await Navigator.push<GameEvent>(
      context,
      MaterialPageRoute(builder: (_) => AddEventScreen(game: _game)),
    );
    if (created != null) _loadEvents();
  }

  Future<void> _openEditEvent(GameEvent event) async {
    final updated = await Navigator.push<GameEvent>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEventScreen(game: _game, existingEvent: event),
      ),
    );
    if (updated != null) _loadEvents();
  }

  void _openViewEvent(GameEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _EventViewScreen(event: event)),
    );
  }

  Future<void> _openEditGame() async {
    final updatedGame = await Navigator.push<Game>(
      context,
      MaterialPageRoute(builder: (_) => AddGameScreen(existingGame: _game)),
    );
    if (updatedGame != null && mounted) {
      setState(() {
        _game = updatedGame;
        _wasEdited = true;
      });
    }
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DetailRow(
          label: 'Genre',
          value: game.genres.isNotEmpty ? game.genres.join(', ') : 'Not set',
        ),
        _DetailRow(label: 'Status', value: game.displayStatus),
        _DetailRow(
          label: 'Release Date',
          value: game.releaseDate ?? 'Coming soon',
        ),
      ],
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({
    required this.events,
    required this.loading,
    required this.error,
    required this.onAddEvent,
    required this.onEditEvent,
    required this.onViewEvent,
    required this.onRetry,
  });

  final List<GameEvent> events;
  final bool loading;
  final String? error;
  final VoidCallback onAddEvent;
  final ValueChanged<GameEvent> onEditEvent;
  final ValueChanged<GameEvent> onViewEvent;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAddEvent,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Event'),
        ),
        const SizedBox(height: 14),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          _EventsPlaceholder(
            message: error!,
            action: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          )
        else if (events.isEmpty)
          const _EventsPlaceholder(message: 'No events yet.')
        else
          for (final event in events) ...[
            _EventCard(
              event: event,
              onEdit: () => onEditEvent(event),
              onView: () => onViewEvent(event),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _EventsPlaceholder extends StatelessWidget {
  const _EventsPlaceholder({required this.message, this.action});

  final String message;
  final Widget? action;

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
        children: [
          Text(message, style: AppTextStyles.bodyMuted),
          if (action != null) ...[const SizedBox(height: 10), action!],
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onEdit,
    required this.onView,
  });

  final GameEvent event;
  final VoidCallback onEdit;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final location = event.location;
    final description = event.description;
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
          Text(event.title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(event.scheduleLabel, style: AppTextStyles.bodyMuted),
          if (location != null && location.isNotEmpty)
            Text(location, style: AppTextStyles.bodyMuted),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(description, style: AppTextStyles.body),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onView,
                  child: const Text('View'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventViewScreen extends StatelessWidget {
  const _EventViewScreen({required this.event});

  final GameEvent event;

  @override
  Widget build(BuildContext context) {
    final location = event.location;
    final description = event.description;
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          _DetailRow(label: 'Date', value: event.formattedDate),
          _DetailRow(label: 'Time', value: event.formattedTime ?? 'Not set'),
          _DetailRow(
            label: 'Location',
            value: (location == null || location.isEmpty)
                ? 'Not set'
                : location,
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Description', style: AppTextStyles.bodyMuted),
            const SizedBox(height: 6),
            Text(description, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }
}

class _FallbackHeader extends StatelessWidget {
  const _FallbackHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD47A3B), Color(0xFF211117)],
        ),
      ),
      child: const Icon(
        Icons.sports_esports_rounded,
        color: Colors.white70,
        size: 88,
      ),
    );
  }
}

class _LinksTab extends StatelessWidget {
  const _LinksTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DetailRow(label: 'Steam', value: 'store.steampowered.com'),
        _DetailRow(label: 'Website', value: 'desertpixel.studio'),
        _DetailRow(label: 'Press Kit', value: 'Available'),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMuted)),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
