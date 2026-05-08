import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/providers/supabase_provider.dart';

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? sessionId;
  final String? error;
  final bool isLocked;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.sessionId,
    this.error,
    this.isLocked = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? sessionId,
    String? error,
    bool? isLocked,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
      error: error ?? this.error,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  ChatNotifier(this._ref) : super(const ChatState());

  static const _crisisKeywords = [
    'suicide', 'self-harm', 'kill myself',
    'end my life', 'want to die',
  ];

  bool containsCrisisKeyword(String text) {
    final lower = text.toLowerCase();
    return _crisisKeywords.any((kw) => lower.contains(kw));
  }

  void lockChat() {
    state = state.copyWith(isLocked: true);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isLoading || state.isLocked) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final client = _ref.read(supabaseClientProvider);
      final session = client.auth.currentSession;
      if (session == null) {
        state = state.copyWith(isLoading: false, error: 'Please sign in');
        return;
      }

      final history = state.messages
          .where((m) => m.role != 'system')
          .toList().reversed.take(20).toList().reversed
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final url = const String.fromEnvironment('SUPABASE_URL');
      final resp = await http.post(
        Uri.parse('$url/functions/v1/ai_proxy'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
        },
        body: jsonEncode({
          'messages': history,
          'sessionId': state.sessionId,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final aiMsg = ChatMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}_ai',
          role: 'assistant',
          content: data['message'] as String,
          createdAt: DateTime.now(),
        );
        state = state.copyWith(
          messages: [...state.messages, aiMsg],
          isLoading: false,
          sessionId: data['sessionId'] as String?,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Something went wrong. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Connection error. Check your internet.',
      );
    }
  }

  void clearChat() => state = const ChatState();
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
