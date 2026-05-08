import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindmentor/features/chat/chat_provider.dart';

void main() {
  group('Crisis Intervention Protocol', () {
    late ProviderContainer container;
    late ChatNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(chatProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    // ── Positive Detection Tests ──────────────────────────────────────
    group('containsCrisisKeyword — positive matches', () {
      test('detects "suicide"', () {
        expect(notifier.containsCrisisKeyword('I am thinking about suicide'), isTrue);
      });

      test('detects "self-harm"', () {
        expect(notifier.containsCrisisKeyword('I want to self-harm'), isTrue);
      });

      test('detects "kill myself"', () {
        expect(notifier.containsCrisisKeyword('I want to kill myself'), isTrue);
      });

      test('detects "end my life"', () {
        expect(notifier.containsCrisisKeyword('I want to end my life'), isTrue);
      });

      test('detects "want to die"', () {
        expect(notifier.containsCrisisKeyword('I want to die'), isTrue);
      });

      test('detects keywords regardless of case', () {
        expect(notifier.containsCrisisKeyword('SUICIDE'), isTrue);
        expect(notifier.containsCrisisKeyword('Kill Myself'), isTrue);
        expect(notifier.containsCrisisKeyword('SELF-HARM is bad'), isTrue);
      });

      test('detects keywords embedded in longer text', () {
        expect(
          notifier.containsCrisisKeyword(
            'I have been thinking a lot and I want to end my life because everything is bad',
          ),
          isTrue,
        );
      });
    });

    // ── Negative Detection Tests ──────────────────────────────────────
    group('containsCrisisKeyword — safe inputs', () {
      test('does NOT flag "I had a hard day"', () {
        expect(notifier.containsCrisisKeyword('I had a hard day'), isFalse);
      });

      test('does NOT flag "I feel anxious"', () {
        expect(notifier.containsCrisisKeyword('I feel anxious'), isFalse);
      });

      test('does NOT flag "I am sad and lonely"', () {
        expect(notifier.containsCrisisKeyword('I am sad and lonely'), isFalse);
      });

      test('does NOT flag "Help me relax"', () {
        expect(notifier.containsCrisisKeyword('Help me relax'), isFalse);
      });

      test('does NOT flag empty string', () {
        expect(notifier.containsCrisisKeyword(''), isFalse);
      });

      test('does NOT flag whitespace only', () {
        expect(notifier.containsCrisisKeyword('   '), isFalse);
      });

      test('does NOT flag "I feel like dying of laughter"', () {
        // This is a known limitation — "want to die" is the phrase, not "dying"
        expect(notifier.containsCrisisKeyword('I feel like dying of laughter'), isFalse);
      });
    });

    // ── Chat Lock Tests ──────────────────────────────────────────────
    group('lockChat behavior', () {
      test('locks the chat session permanently', () {
        expect(container.read(chatProvider).isLocked, isFalse);

        notifier.lockChat();

        expect(container.read(chatProvider).isLocked, isTrue);
      });

      test('sendMessage does nothing when chat is locked', () async {
        notifier.lockChat();

        // Attempting to send should be a no-op
        await notifier.sendMessage('This should not send');

        // Only state should be locked, no messages added
        final state = container.read(chatProvider);
        expect(state.messages, isEmpty);
        expect(state.isLocked, isTrue);
      });
    });

    // ── ChatState Tests ──────────────────────────────────────────────
    group('ChatState', () {
      test('default state has no messages and is not loading', () {
        const state = ChatState();
        expect(state.messages, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.sessionId, isNull);
        expect(state.error, isNull);
        expect(state.isLocked, isFalse);
      });

      test('copyWith preserves unmodified fields', () {
        const state = ChatState(isLoading: true);
        final updated = state.copyWith(isLocked: true);

        expect(updated.isLoading, isTrue); // preserved
        expect(updated.isLocked, isTrue); // updated
      });

      test('copyWith clearError resets error', () {
        const state = ChatState(error: 'Something went wrong');
        final updated = state.copyWith(clearError: true);

        expect(updated.error, isNull);
      });
    });
  });
}
