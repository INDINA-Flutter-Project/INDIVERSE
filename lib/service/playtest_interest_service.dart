import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/playtester_interest.dart';

class PlaytestInterestService {
  PlaytestInterestService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  static const _table = 'playtest_interests';
  final SupabaseClient supabase;

  Future<bool> hasInterest({required int gameId, required String playerId}) async {
    final rows = await supabase
        .from(_table)
        .select('id')
        .eq('game_id', gameId)
        .eq('player_id', playerId)
        .limit(1);
    return rows.isNotEmpty;
  }

  Future<void> registerInterest({required int gameId}) async {
    await supabase.from(_table).insert({'game_id': gameId});
  }

  Future<void> removeInterest({required int gameId, required String playerId}) async {
    await supabase
        .from(_table)
        .delete()
        .eq('game_id', gameId)
        .eq('player_id', playerId);
  }

  Future<List<PlaytesterInterest>> getInterestsForDeveloper(
    String developerId,
  ) async {
    final interestRows = await supabase
        .from(_table)
        .select('id, player_id, games_made_in_ksa!inner(name, developer_id)')
        .eq('games_made_in_ksa.developer_id', developerId)
        .order('created_at', ascending: false);

    if (interestRows.isEmpty) return const <PlaytesterInterest>[];

    final playerIds = interestRows
        .map((row) => row['player_id'] as String)
        .toSet()
        .toList();

    final profileRows = await supabase
        .from('profiles')
        .select('id, name, email')
        .inFilter('id', playerIds);

    final profileById = {
      for (final profile in profileRows) profile['id'] as String: profile,
    };

    return interestRows.map((row) {
      final game = row['games_made_in_ksa'] as Map<String, dynamic>?;
      final profile = profileById[row['player_id'] as String];
      return PlaytesterInterest(
        id: row['id'] as int,
        playerName: profile?['name'] as String?,
        playerEmail: profile?['email'] as String? ?? 'Unknown email',
        gameName: game?['name'] as String? ?? 'Unknown game',
      );
    }).toList(growable: false);
  }
}
