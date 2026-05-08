/// Immutable data model for mood log entries from Supabase `mood_logs` table.
class MoodLog {
  final String id;
  final String userId;
  final int score;
  final String moodLabel;
  final String note;
  final DateTime loggedAt;
  final DateTime createdAt;

  const MoodLog({
    required this.id,
    required this.userId,
    required this.score,
    required this.moodLabel,
    required this.note,
    required this.loggedAt,
    required this.createdAt,
  });

  /// Construct from Supabase row JSON.
  factory MoodLog.fromJson(Map<String, dynamic> json) {
    return MoodLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      score: json['score'] as int,
      moodLabel: json['mood_label'] as String,
      note: (json['note'] as String?) ?? '',
      loggedAt: DateTime.parse(json['logged_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Serialize to JSON for Supabase insert.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'score': score,
      'mood_label': moodLabel,
      'note': note,
      'logged_at': loggedAt.toIso8601String(),
    };
  }

  MoodLog copyWith({
    String? id,
    String? userId,
    int? score,
    String? moodLabel,
    String? note,
    DateTime? loggedAt,
    DateTime? createdAt,
  }) {
    return MoodLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      moodLabel: moodLabel ?? this.moodLabel,
      note: note ?? this.note,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodLog &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
