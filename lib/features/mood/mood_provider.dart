import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/supabase_provider.dart';

/// Data model for a mood log entry.
class MoodLog {
  final String id;
  final String userId;
  final int score;
  final String moodLabel;
  final String note;
  final DateTime loggedAt;

  MoodLog({
    required this.id,
    required this.userId,
    required this.score,
    required this.moodLabel,
    required this.note,
    required this.loggedAt,
  });

  factory MoodLog.fromMap(Map<String, dynamic> map) {
    return MoodLog(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      score: map['score'] as int,
      moodLabel: map['mood_label'] as String,
      note: (map['note'] as String?) ?? '',
      loggedAt: DateTime.parse(map['logged_at'] as String),
    );
  }
}

/// Notifier for managing mood log CRUD operations.
class MoodLogsNotifier extends AsyncNotifier<List<MoodLog>> {
  @override
  Future<List<MoodLog>> build() async {
    return _fetchMoodLogs();
  }

  Future<List<MoodLog>> _fetchMoodLogs() async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('mood_logs')
        .select()
        .eq('user_id', userId)
        .order('logged_at', ascending: false)
        .limit(50);

    return (response as List)
        .map((e) => MoodLog.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> logMood({
    required int score,
    required String label,
    String note = '',
  }) async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('mood_logs').insert({
      'user_id': userId,
      'score': score,
      'mood_label': label,
      'note': note,
      'logged_at': DateTime.now().toIso8601String(),
    });

    // Refresh the list
    ref.invalidateSelf();
  }
}

final moodLogsProvider =
    AsyncNotifierProvider<MoodLogsNotifier, List<MoodLog>>(
  MoodLogsNotifier.new,
);

/// Provides just the 5 most recent moods for the home screen.
final recentMoodsProvider = FutureProvider<List<MoodLog>>((ref) async {
  final moods = await ref.watch(moodLogsProvider.future);
  return moods.take(5).toList();
});

/// Provides mood logs for a specific month (for insights).
final monthlyMoodsProvider =
    FutureProvider.family<List<MoodLog>, DateTime>((ref, month) async {
  final allMoods = await ref.watch(moodLogsProvider.future);
  return allMoods
      .where((m) =>
          m.loggedAt.year == month.year && m.loggedAt.month == month.month)
      .toList();
});
