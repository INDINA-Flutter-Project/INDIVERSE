import 'package:indina/models/game.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Database {
  Database({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  static const _gamesTable = 'games_made_in_ksa';
  final SupabaseClient supabase;

  Future<List<Game>> getAllGames() async {
    final rows = await supabase.from(_gamesTable).select();

    return rows.map(Game.fromJson).toList(growable: false);
  }

  Future<List<Game>> getGamesByDeveloper(String developerId) async {
    final rows = await supabase
        .from(_gamesTable)
        .select()
        .eq('developer_id', developerId);

    return rows.map(Game.fromJson).toList(growable: false);
  }

  Future<void> addGame(Game model) async {
    await supabase.from(_gamesTable).insert({
      'name': model.name,
      'developer': model.developer,
      'genres': model.genres,
      'arabic_support': model.arabicSupport,
      'awards': model.awards,
      if (model.publisher != null) 'publisher': model.publisher,
      if (model.releaseDate != null) 'release_date': model.releaseDate,
      if (model.priceUsd != null) 'price_usd': model.priceUsd,
      if (model.status != null) 'status': model.status,
      if (model.shortDescription != null)
        'short_description': model.shortDescription,
      if (model.description != null) 'description': model.description,
      if (model.coverImage != null) 'cover_image': model.coverImage,
      if (model.steamUrl != null) 'steam_url': model.steamUrl,
      if (model.extraLinks != null) 'extra_links': model.extraLinks,
      if (model.developerId != null) 'developer_id': model.developerId,
    });
  }

  Future<void> removeGame(int id) async {
    await supabase.from(_gamesTable).delete().eq('id', id);
  }
}
