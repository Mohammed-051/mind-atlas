import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Mock Classes
// ═══════════════════════════════════════════════════════════════════════════

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockGoRouter extends Mock implements GoRouter {}

// ═══════════════════════════════════════════════════════════════════════════
// Test Wrapper Widget
// ═══════════════════════════════════════════════════════════════════════════

/// Wraps a widget in [MaterialApp] with a basic theme for widget testing.
///
/// Optionally accepts Riverpod [overrides] for provider injection.
Widget createTestApp(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

/// Wraps a full-screen widget (like a screen) without extra Scaffold.
Widget createTestScreen(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Test Data Factories
// ═══════════════════════════════════════════════════════════════════════════

/// Standard Supabase-format mood log JSON.
Map<String, dynamic> createMoodLogJson({
  String id = 'test-mood-001',
  String userId = 'user-123',
  int score = 4,
  String moodLabel = 'good',
  String note = 'Feeling productive today',
  DateTime? loggedAt,
  DateTime? createdAt,
}) {
  final now = DateTime.now();
  return {
    'id': id,
    'user_id': userId,
    'score': score,
    'mood_label': moodLabel,
    'note': note,
    'logged_at': (loggedAt ?? now).toIso8601String(),
    'created_at': (createdAt ?? now).toIso8601String(),
  };
}

/// Standard Supabase-format chat message JSON.
Map<String, dynamic> createMessageJson({
  String id = 'msg-001',
  String sessionId = 'session-001',
  String userId = 'user-123',
  String role = 'user',
  String content = 'Hello MindMentor',
  DateTime? createdAt,
}) {
  return {
    'id': id,
    'session_id': sessionId,
    'user_id': userId,
    'role': role,
    'content': content,
    'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
  };
}
