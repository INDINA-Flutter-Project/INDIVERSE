class ContentCreator {
  const ContentCreator({
    required this.id,
    required this.name,
    required this.platform,
    required this.channelUrl,
    required this.subscribers,
    required this.genres,
    required this.contentTypes,
    required this.country,
    required this.language,
  });

  final int id;
  final String name;
  final String platform;
  final String channelUrl;
  final int subscribers;
  final List<String> genres;
  final List<String> contentTypes;
  final String country;
  final String language;

  factory ContentCreator.fromJson(Map<String, dynamic> json) {
    return ContentCreator(
      id: json['id'] as int,
      name: json['name'] as String,
      platform: json['platform'] as String,
      channelUrl: json['channel_url'] as String,
      subscribers: json['subscribers'] as int,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      contentTypes:
          (json['content_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      country: json['country'] as String,
      language: json['language'] as String,
    );
  }
}
