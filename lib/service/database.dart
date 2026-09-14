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

  Future<void> addGame(Game model) async {
    await supabase.from(_gamesTable).insert({
      'name': model.name,
      'developer': model.developer,
      'publisher': model.publisher,
      'genres': model.genres,
      'release_date': model.releaseDate,
      'price_usd': model.priceUsd,
      'status': model.status,
      'short_description': model.shortDescription,
      'description': model.description,
      'cover_image': model.coverImage,
      'arabic_support': model.arabicSupport,
      'steam_url': model.steamUrl,
      'extra_links': model.extraLinks,
      'awards': model.awards,
    });
  }

  Future<void> removeGame(int id) async {
    await supabase.from(_gamesTable).delete().eq('id', id);
  }
}
