class UserPreferences {
  const UserPreferences({
    required this.userId,
    this.genres = const [],
    this.platforms = const [],
    this.languages = const [],
    this.gameStages = const [],
    this.playStyles = const [],
  });

  final String userId;
  final List<String> genres;
  final List<String> platforms;
  final List<String> languages;
  final List<String> gameStages;
  final List<String> playStyles;

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'] as String,
      genres: _stringList(json['genres']),
      platforms: _stringList(json['platforms']),
      languages: _stringList(json['languages']),
      gameStages: _stringList(json['game_stages']),
      playStyles: _stringList(json['play_styles']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'genres': genres,
      'platforms': platforms,
      'languages': languages,
      'game_stages': gameStages,
      'play_styles': playStyles,
    };
  }

  UserPreferences copyWith({
    List<String>? genres,
    List<String>? platforms,
    List<String>? languages,
    List<String>? gameStages,
    List<String>? playStyles,
  }) {
    return UserPreferences(
      userId: userId,
      genres: genres ?? this.genres,
      platforms: platforms ?? this.platforms,
      languages: languages ?? this.languages,
      gameStages: gameStages ?? this.gameStages,
      playStyles: playStyles ?? this.playStyles,
    );
  }

  static List<String> _stringList(dynamic value) {
    return (value as List<dynamic>?)?.map((item) => item.toString()).toList() ??
        const [];
  }
}
