import 'package:flutter_test/flutter_test.dart';
import 'package:mindmentor/core/models/message.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ChatMessage', () {
    // ── fromJson Tests ─────────────────────────────────────────────────
    group('fromJson', () {
      test('parses standard Supabase row correctly', () {
        final json = createMessageJson(
          id: 'msg-abc',
          sessionId: 'session-xyz',
          userId: 'user-123',
          role: 'user',
          content: 'How are you?',
          createdAt: DateTime(2026, 5, 8, 15, 0),
        );

        final msg = ChatMessage.fromJson(json);

        expect(msg.id, 'msg-abc');
        expect(msg.sessionId, 'session-xyz');
        expect(msg.userId, 'user-123');
        expect(msg.role, 'user');
        expect(msg.content, 'How are you?');
        expect(msg.createdAt.year, 2026);
      });

      test('handles null session_id and user_id', () {
        final json = createMessageJson();
        json['session_id'] = null;
        json['user_id'] = null;

        final msg = ChatMessage.fromJson(json);
        expect(msg.sessionId, isNull);
        expect(msg.userId, isNull);
      });

      test('parses assistant role', () {
        final json = createMessageJson(role: 'assistant');
        final msg = ChatMessage.fromJson(json);
        expect(msg.role, 'assistant');
      });
    });

    // ── toJson Tests ───────────────────────────────────────────────────
    group('toJson', () {
      test('serializes to Supabase insert format', () {
        final msg2 = ChatMessage(
          id: 'test-id',
          sessionId: 'session-1',
          userId: 'user-1',
          role: 'user',
          content: 'Hello world',
          createdAt: DateTime(2026, 5, 8),
        );

        final json = msg2.toJson();
        expect(json['role'], 'user');
        expect(json['content'], 'Hello world');
        expect(json['session_id'], 'session-1');
        expect(json['user_id'], 'user-1');
      });

      test('omits null session_id and user_id from JSON', () {
        final msg = ChatMessage(
          id: 'test',
          role: 'assistant',
          content: 'I am here',
          createdAt: DateTime.now(),
        );

        final json = msg.toJson();
        expect(json.containsKey('session_id'), isFalse);
        expect(json.containsKey('user_id'), isFalse);
      });
    });

    // ── local Factory Tests ────────────────────────────────────────────
    group('local factory', () {
      test('creates a message with "local_" prefixed id', () {
        final msg = ChatMessage.local(role: 'user', content: 'Test');
        expect(msg.id, startsWith('local_'));
      });

      test('creates a message with correct role and content', () {
        final msg = ChatMessage.local(role: 'assistant', content: 'AI response');
        expect(msg.role, 'assistant');
        expect(msg.content, 'AI response');
      });

      test('has null sessionId and userId', () {
        final msg = ChatMessage.local(role: 'user', content: 'Test');
        expect(msg.sessionId, isNull);
        expect(msg.userId, isNull);
      });
    });

    // ── toApiPayload Tests ─────────────────────────────────────────────
    group('toApiPayload', () {
      test('returns only role and content', () {
        final msg = ChatMessage(
          id: 'test',
          sessionId: 'session',
          userId: 'user',
          role: 'user',
          content: 'Hello',
          createdAt: DateTime.now(),
        );

        final payload = msg.toApiPayload();
        expect(payload.length, 2);
        expect(payload['role'], 'user');
        expect(payload['content'], 'Hello');
      });
    });

    // ── Equality Tests ─────────────────────────────────────────────────
    group('equality', () {
      test('messages with same id are equal', () {
        final a = ChatMessage(
          id: 'same-id',
          role: 'user',
          content: 'A',
          createdAt: DateTime.now(),
        );
        final b = ChatMessage(
          id: 'same-id',
          role: 'assistant',
          content: 'B',
          createdAt: DateTime.now(),
        );

        expect(a, equals(b));
      });

      test('messages with different ids are not equal', () {
        final a = ChatMessage(
          id: 'id-1',
          role: 'user',
          content: 'Same',
          createdAt: DateTime.now(),
        );
        final b = ChatMessage(
          id: 'id-2',
          role: 'user',
          content: 'Same',
          createdAt: DateTime.now(),
        );

        expect(a, isNot(equals(b)));
      });
    });
  });
}
