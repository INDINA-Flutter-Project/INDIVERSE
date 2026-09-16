import 'content_creator.dart';

class CreatorRequest {
  const CreatorRequest({
    required this.id,
    required this.campaignId,
    required this.creatorId,
    required this.status,
    required this.message,
    required this.createdAt,
    required this.creator,
  });

  final int id;
  final int campaignId;
  final int creatorId;
  final String status;
  final String message;
  final DateTime? createdAt;
  final ContentCreator creator;

  factory CreatorRequest.fromJson(Map<String, dynamic> json) {
    return CreatorRequest(
      id: json['id'] as int,
      campaignId: json['campaign_id'] as int,
      creatorId: json['creator_id'] as int,
      status: json['status'] as String,
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      creator: ContentCreator.fromJson(
        json['content_creators'] as Map<String, dynamic>,
      ),
    );
  }
}
