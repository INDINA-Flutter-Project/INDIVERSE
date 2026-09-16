import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/creator_campaign.dart';

class CreatorCampaignService {
  CreatorCampaignService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  static const _table = 'creator_campaigns';
  final SupabaseClient supabase;

  Future<List<CreatorCampaign>> getCampaignsForDeveloper(
    List<int> gameIds,
  ) async {
    if (gameIds.isEmpty) return const <CreatorCampaign>[];

    final rows = await supabase
        .from(_table)
        .select()
        .inFilter('game_id', gameIds)
        .order('created_at', ascending: false);

    return rows.map(CreatorCampaign.fromJson).toList(growable: false);
  }

  Future<CreatorCampaign> createCampaign({
    required int gameId,
    required String platform,
    required String contentType,
    required int keyCount,
    required String status,
  }) async {
    final row = await supabase
        .from(_table)
        .insert({
          'game_id': gameId,
          'platform': platform,
          'content_type': contentType,
          'key_count': keyCount,
          'status': status,
        })
        .select()
        .single();

    return CreatorCampaign.fromJson(row);
  }

  Future<CreatorCampaign> updateCampaign({
    required int campaignId,
    required int gameId,
    required String platform,
    required String contentType,
    required int keyCount,
    required String status,
  }) async {
    final row = await supabase
        .from(_table)
        .update({
          'game_id': gameId,
          'platform': platform,
          'content_type': contentType,
          'key_count': keyCount,
          'status': status,
        })
        .eq('id', campaignId)
        .select()
        .single();

    return CreatorCampaign.fromJson(row);
  }
}
