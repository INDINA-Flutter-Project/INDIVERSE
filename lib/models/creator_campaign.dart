class CreatorCampaign {
  const CreatorCampaign({
    required this.id,
    required this.gameId,
    required this.platform,
    required this.contentType,
    required this.keyCount,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int gameId;
  final String platform;
  final String contentType;
  final int keyCount;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CreatorCampaign.fromJson(Map<String, dynamic> json) {
    return CreatorCampaign(
      id: json['id'] as int,
      gameId: json['game_id'] as int,
      platform: json['platform'] as String,
      contentType: json['content_type'] as String,
      keyCount: json['key_count'] as int,
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}
