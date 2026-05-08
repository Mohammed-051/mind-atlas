import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/mood_log.dart';
import '../../core/providers/supabase_provider.dart';

// Re-export so existing imports like `home_screen.dart` still work
export '../../core/models/mood_log.dart';

/// Notifier for managing mood log CRUD operations via Supabase.
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
        .limit(100);

    return (response as List)
        .map((e) => MoodLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Insert a new mood entry for the authenticated user.
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

    // Refresh the list from database
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

/// Provides mood logs for a specific month (for insights calendar).
final monthlyMoodsProvider =
    FutureProvider.family<List<MoodLog>, DateTime>((ref, month) async {
  final allMoods = await ref.watch(moodLogsProvider.future);
  return allMoods
      .where((m) =>
          m.loggedAt.year == month.year && m.loggedAt.month == month.month)
      .toList();
});
