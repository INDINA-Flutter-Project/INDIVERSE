import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_event.dart';

class GameEventService {
  GameEventService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  static const _table = 'game_events';
  final SupabaseClient supabase;

  Future<List<GameEvent>> getEventsForGame(int gameId) async {
    final rows = await supabase
        .from(_table)
        .select()
        .eq('game_id', gameId)
        .order('event_date');

    return rows.map(GameEvent.fromJson).toList(growable: false);
  }

  Future<GameEvent> addEvent({
    required int gameId,
    required String title,
    required DateTime eventDate,
    String? eventTime,
    String? location,
    String? description,
  }) async {
    final row = await supabase
        .from(_table)
        .insert({
          'game_id': gameId,
          'title': title,
          'event_date': _dateOnly(eventDate),
          if (eventTime != null) 'event_time': eventTime,
          if (location != null) 'location': location,
          if (description != null) 'description': description,
        })
        .select()
        .single();

    return GameEvent.fromJson(row);
  }

  Future<GameEvent> updateEvent(GameEvent event) async {
    final rows = await supabase
        .from(_table)
        .update({
          'title': event.title,
          'event_date': _dateOnly(event.eventDate),
          'event_time': event.eventTime,
          'location': event.location,
          'description': event.description,
        })
        .eq('id', event.id)
        .select();

    if (rows.isEmpty) {
      throw Exception(
        'No event was updated — this usually means Supabase Row Level '
        'Security has no UPDATE policy allowing this on "game_events".',
      );
    }

    return GameEvent.fromJson(rows.first);
  }

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
