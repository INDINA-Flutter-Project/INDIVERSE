import 'package:indina/models/game.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Database {
  final supabase = Supabase.instance.client;
 
  Future<List<Game>> getAllGames() async {
    final data = await supabase.from('games_made_in_ksa').select();
    List<Game> allGames = [];
    for (var e in data) {
      allGames.add(Game.fromJson(e));
    }
 
    return allGames;
  }
 
  addGame(Game model) async {
    await supabase.from('games_made_in_ksa').insert({
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
 
  removeGame(int id) async {
    await supabase.from('games_made_in_ksa').delete().eq('id', id);
  }
}