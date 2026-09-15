class PlaytesterInterest {
  const PlaytesterInterest({
    required this.id,
    required this.playerName,
    required this.playerEmail,
    required this.gameName,
  });

  final int id;
  final String? playerName;
  final String playerEmail;
  final String gameName;

  factory PlaytesterInterest.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final game = json['games_made_in_ksa'] as Map<String, dynamic>?;
    return PlaytesterInterest(
      id: json['id'] as int,
      playerName: profile?['name'] as String?,
      playerEmail: profile?['email'] as String? ?? 'Unknown email',
      gameName: game?['name'] as String? ?? 'Unknown game',
    );
  }
}
