import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/creator_request.dart';

const creatorRequestStatuses = {'pending', 'accepted', 'declined'};

const _selectWithCreator =
    'id, campaign_id, creator_id, status, message, created_at, '
    'content_creators!inner('
    'id, name, platform, channel_url, subscribers, genres, '
    'content_types, country, language'
    ')';

class CreatorRequestService {
  CreatorRequestService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  static const _table = 'creator_requests';
  final SupabaseClient supabase;

  Future<List<CreatorRequest>> getRequestsForCampaign(int campaignId) async {
    final rows = await supabase
        .from(_table)
        .select(_selectWithCreator)
        .eq('campaign_id', campaignId)
        .order('created_at', ascending: false);

    return rows.map(CreatorRequest.fromJson).toList(growable: false);
  }

  Future<CreatorRequest> updateRequestStatus({
    required int requestId,
    required String status,
  }) async {
    if (!creatorRequestStatuses.contains(status)) {
      throw ArgumentError.value(
        status,
        'status',
        'Invalid creator request status',
      );
    }

    final row = await supabase
        .from(_table)
        .update({'status': status})
        .eq('id', requestId)
        .select(_selectWithCreator)
        .single();

    return CreatorRequest.fromJson(row);
  }
}
