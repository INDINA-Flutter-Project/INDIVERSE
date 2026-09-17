class GameEvent {
  const GameEvent({
    required this.id,
    required this.gameId,
    required this.title,
    required this.eventDate,
    this.eventTime,
    this.location,
    this.description,
  });

  final int id;
  final int gameId;
  final String title;
  final DateTime eventDate;

  /// Stored as Postgres `time` text, e.g. "16:00:00".
  final String? eventTime;
  final String? location;
  final String? description;

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(
      id: json['id'] as int,
      gameId: json['game_id'] as int,
      title: json['title'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventTime: json['event_time'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
    );
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String formatDate(DateTime date) =>
      '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

  String get formattedDate => formatDate(eventDate);

  String? get formattedTime {
    final raw = eventTime;
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour24 = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour24 == null || minute == null) return raw;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  String get scheduleLabel {
    final time = formattedTime;
    return time == null ? formattedDate : '$formattedDate • $time';
  }
}
