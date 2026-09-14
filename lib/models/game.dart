class Game {
  final int id;
  final String name;
  final String? developer;
  final String? publisher;
  final List<String> genres;
  final String? releaseDate;
  final String? priceUsd;
  final String? status;
  final String? shortDescription;
  final String? description;
  final String? coverImage;
  final bool arabicSupport;
  final String? steamUrl;
  final String? extraLinks;
  final List<String> awards;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Game({
    required this.id,
    required this.name,
    this.developer,
    this.publisher,
    this.genres = const [],
    this.releaseDate,
    this.priceUsd,
    this.status,
    this.shortDescription,
    this.description,
    this.coverImage,
    this.arabicSupport = false,
    this.steamUrl,
    this.extraLinks,
    this.awards = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as int,
      name: json['name'] as String,
      developer: json['developer'] as String?,
      publisher: json['publisher'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      releaseDate: json['release_date'] as String?,
      priceUsd: json['price_usd'] as String?,
      status: json['status'] as String?,
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String? ?? '',
      arabicSupport: json['arabic_support'] as bool? ?? false,
      steamUrl: json['steam_url'] as String?,
      extraLinks: json['extra_links'] as String?,
      awards:
          (json['awards'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}
