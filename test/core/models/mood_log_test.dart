import 'package:flutter_test/flutter_test.dart';
import 'package:mindmentor/core/models/mood_log.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('MoodLog', () {
    // ── fromJson Tests ─────────────────────────────────────────────────
    group('fromJson', () {
      test('parses standard Supabase row correctly', () {
        final json = createMoodLogJson(
          id: 'uuid-abc',
          userId: 'user-456',
          score: 5,
          moodLabel: 'great',
          note: 'Amazing day!',
          loggedAt: DateTime(2026, 5, 8, 14, 30),
          createdAt: DateTime(2026, 5, 8, 14, 30),
        );

        final mood = MoodLog.fromJson(json);

        expect(mood.id, 'uuid-abc');
        expect(mood.userId, 'user-456');
        expect(mood.score, 5);
        expect(mood.moodLabel, 'great');
        expect(mood.note, 'Amazing day!');
        expect(mood.loggedAt, DateTime(2026, 5, 8, 14, 30));
      });

      test('handles null note by defaulting to empty string', () {
        final json = createMoodLogJson();
        json['note'] = null;

        final mood = MoodLog.fromJson(json);
        expect(mood.note, '');
      });

      test('handles ISO 8601 date strings with timezone', () {
        final json = createMoodLogJson();
        json['logged_at'] = '2026-05-08T14:30:00.000Z';
        json['created_at'] = '2026-05-08T14:30:00.000Z';

        final mood = MoodLog.fromJson(json);
        expect(mood.loggedAt.year, 2026);
        expect(mood.loggedAt.month, 5);
        expect(mood.loggedAt.day, 8);
      });

      test('parses all valid mood labels', () {
        for (final label in ['awful', 'bad', 'okay', 'good', 'great']) {
          final json = createMoodLogJson(moodLabel: label);
          final mood = MoodLog.fromJson(json);
          expect(mood.moodLabel, label);
        }
      });

      test('parses all valid scores 1-5', () {
        for (var score = 1; score <= 5; score++) {
          final json = createMoodLogJson(score: score);
          final mood = MoodLog.fromJson(json);
          expect(mood.score, score);
        }
      });
    });

    // ── toJson Tests ───────────────────────────────────────────────────
    group('toJson', () {
      test('serializes to correct Supabase insert format', () {
        final mood = MoodLog(
          id: 'test-id',
          userId: 'user-789',
          score: 3,
          moodLabel: 'okay',
          note: 'Just another day',
          loggedAt: DateTime(2026, 5, 8, 10, 0),
          createdAt: DateTime(2026, 5, 8, 10, 0),
        );

        final json = mood.toJson();

        expect(json['user_id'], 'user-789');
        expect(json['score'], 3);
        expect(json['mood_label'], 'okay');
        expect(json['note'], 'Just another day');
        expect(json['logged_at'], contains('2026-05-08'));
      });

      test('does NOT include id in toJson (server-generated)', () {
        final mood = MoodLog(
          id: 'should-not-appear',
          userId: 'user-789',
          score: 1,
          moodLabel: 'awful',
          note: '',
          loggedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final json = mood.toJson();
        expect(json.containsKey('id'), isFalse);
      });

      test('does NOT include created_at in toJson (server-generated)', () {
        final mood = MoodLog(
          id: 'test',
          userId: 'user',
          score: 4,
          moodLabel: 'good',
          note: '',
          loggedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final json = mood.toJson();
        expect(json.containsKey('created_at'), isFalse);
      });
    });

    // ── Equality Tests ─────────────────────────────────────────────────
    group('equality', () {
      test('two MoodLogs with same id are equal', () {
        final a = MoodLog(
          id: 'same-id',
          userId: 'u1',
          score: 3,
          moodLabel: 'okay',
          note: '',
          loggedAt: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        );
        final b = MoodLog(
          id: 'same-id',
          userId: 'u2', // Different userId but same id
          score: 5,
          moodLabel: 'great',
          note: 'Different',
          loggedAt: DateTime(2026, 2, 1),
          createdAt: DateTime(2026, 2, 1),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('two MoodLogs with different ids are not equal', () {
        final a = MoodLog(
          id: 'id-1',
          userId: 'u1',
          score: 3,
          moodLabel: 'okay',
          note: '',
          loggedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        final b = MoodLog(
          id: 'id-2',
          userId: 'u1',
          score: 3,
          moodLabel: 'okay',
          note: '',
          loggedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(a, isNot(equals(b)));
      });
    });

    // ── copyWith Tests ─────────────────────────────────────────────────
    group('copyWith', () {
      test('creates a copy with modified fields', () {
        final original = MoodLog(
          id: 'test-id',
          userId: 'user-1',
          score: 3,
          moodLabel: 'okay',
          note: 'Original',
          loggedAt: DateTime(2026, 5, 1),
          createdAt: DateTime(2026, 5, 1),
        );

        final copy = original.copyWith(score: 5, moodLabel: 'great');

        expect(copy.score, 5);
        expect(copy.moodLabel, 'great');
        expect(copy.id, 'test-id'); // Unchanged
        expect(copy.note, 'Original'); // Unchanged
      });
    });
  });
}
