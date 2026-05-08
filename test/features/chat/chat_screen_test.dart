import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mindmentor/features/chat/chat_screen.dart';
import 'package:mindmentor/features/chat/chat_provider.dart';

class MockChatNotifier extends StateNotifier<ChatState> with Mock implements ChatNotifier {
  MockChatNotifier(super.state);
}

void main() {
  group('ChatScreen Widget Tests', () {
    late MockChatNotifier mockNotifier;
    late GoRouter testRouter;

    setUp(() {
      mockNotifier = MockChatNotifier(const ChatState());

      // Stub default behaviors
      when(() => mockNotifier.initializeChat()).thenAnswer((_) async {});
      when(() => mockNotifier.sendMessage(any())).thenAnswer((_) async {});
      when(() => mockNotifier.lockChat()).thenAnswer((_) {
        mockNotifier.state = const ChatState(isLocked: true);
      });

      testRouter = GoRouter(
        initialLocation: '/chat',
        routes: [
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/emergency',
            builder: (context, state) => const Scaffold(
              body: Text('Emergency Screen'),
            ),
          ),
        ],
      );
    });

    testWidgets('typing a crisis keyword triggers GoRouter redirect to /emergency', (WidgetTester tester) async {
      // Stub the crisis detection logic
      when(() => mockNotifier.containsCrisisKeyword('hello')).thenReturn(false);
      when(() => mockNotifier.containsCrisisKeyword('suicide')).thenReturn(true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatProvider.overrideWith((ref) => mockNotifier),
          ],
          child: MaterialApp.router(
            routerConfig: testRouter,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we are on the Chat Screen
      expect(find.byType(ChatScreen), findsOneWidget);

      // Find the TextField and the send button
      final textField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send_rounded);

      expect(textField, findsOneWidget);
      expect(sendButton, findsOneWidget);

      // First, send a safe message to ensure it DOES NOT redirect
      await tester.enterText(textField, 'hello');
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Verify we are still on the Chat Screen
      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.text('Emergency Screen'), findsNothing);
      verify(() => mockNotifier.sendMessage('hello')).called(1);

      // Now, send a crisis keyword
      await tester.enterText(textField, 'suicide');
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Verify that lockChat was called
      verify(() => mockNotifier.lockChat()).called(1);

      // Verify GoRouter navigated to /emergency
      expect(find.byType(ChatScreen), findsNothing);
      expect(find.text('Emergency Screen'), findsOneWidget);
    });
  });
}
