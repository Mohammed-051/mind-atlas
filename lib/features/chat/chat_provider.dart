import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/message.dart';
import '../../core/providers/error_reporter.dart';
import '../../core/providers/supabase_provider.dart';
import '../../core/providers/auth_provider.dart';

// Re-export so chat_screen.dart can use ChatMessage
export '../../core/models/message.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Chat State
// ═══════════════════════════════════════════════════════════════════════════

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
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
      error: clearError ? null : (error ?? this.error),
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Chat Notifier — Supabase + Edge Function Integration
// ═══════════════════════════════════════════════════════════════════════════

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  ChatNotifier(this._ref) : super(const ChatState());

  // ── Crisis Detection ───────────────────────────────────────────────────
  static const _crisisKeywords = [
    'suicide',
    'self-harm',
    'kill myself',
    'end my life',
    'want to die',
  ];

  /// Check if the text contains crisis keywords.
  /// This MUST be called BEFORE sendMessage in the UI layer.
  bool containsCrisisKeyword(String text) {
    final lower = text.toLowerCase();
    return _crisisKeywords.any((kw) => lower.contains(kw));
  }

  /// Lock the chat permanently for this session (crisis protocol).
  void lockChat() {
    state = state.copyWith(isLocked: true);
  }

  // ── Session Management ─────────────────────────────────────────────────

  /// Fetch or create a chat session for the current user.
  Future<String> _ensureSession() async {
    // Return existing session if available
    if (state.sessionId != null) return state.sessionId!;

    final client = _ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Try to find today's active session
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();

    final existing = await client
        .from('chat_sessions')
        .select('id')
        .eq('user_id', userId)
        .eq('is_active', true)
        .gte('created_at', startOfDay)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      final sessionId = existing['id'] as String;
      state = state.copyWith(sessionId: sessionId);

      // Load existing messages for this session
      await _loadSessionMessages(sessionId);
      return sessionId;
    }

    // Create a new session
    final newSession = await client
        .from('chat_sessions')
        .insert({
          'user_id': userId,
          'title': 'Session ${today.month}/${today.day}',
          'is_active': true,
        })
        .select('id')
        .single();

    final sessionId = newSession['id'] as String;
    state = state.copyWith(sessionId: sessionId);
    return sessionId;
  }

  /// Load persisted messages for a given session.
  Future<void> _loadSessionMessages(String sessionId) async {
    final client = _ref.read(supabaseClientProvider);

    final rows = await client
        .from('messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true)
        .limit(100);

    final messages = (rows as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();

    state = state.copyWith(messages: messages);
  }

  /// Initialize the chat — call this when the chat screen mounts.
  Future<void> initializeChat() async {
    if (state.sessionId != null) return; // Already initialized

    final client = _ref.read(supabaseClientProvider);
    if (client.auth.currentSession == null) {
      final isGuest = _ref.read(guestModeProvider);
      state = state.copyWith(
        isLoading: false,
        error: isGuest
            ? 'Chat is unavailable in guest mode. Please sign in.'
            : 'Please sign in to chat.',
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _ensureSession();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Chat init error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to start chat session.',
      );
    }
  }

  // ── Send Message ───────────────────────────────────────────────────────

  /// Send a message to the AI via the Edge Function.
  ///
  /// Flow:
  ///   1. Optimistically add user message to UI
  ///   2. Invoke Edge Function with message history
  ///   3. Parse AI response and update UI
  ///   4. Messages are persisted server-side by the Edge Function
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isLoading || state.isLocked) return;

    final trimmed = content.trim();
    final client = _ref.read(supabaseClientProvider);
    final session = client.auth.currentSession;

    if (session == null) {
      state = state.copyWith(error: 'Please sign in to chat.');
      return;
    }

    // Ensure we have a session ID
    String sessionId;
    try {
      sessionId = await _ensureSession();
    } catch (e) {
      state = state.copyWith(error: 'Unable to create chat session.');
      return;
    }

    // 1. Optimistically add user message
    final userMsg = ChatMessage.local(role: 'user', content: trimmed);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
    );

    try {
      // 2. Build message history for the API (last 20 messages)
      final history = state.messages
          .where((m) => m.role != 'system')
          .toList()
          .reversed
          .take(20)
          .toList()
          .reversed
          .map((m) => m.toApiPayload())
          .toList();

      // 3. Invoke the Edge Function via Supabase client
      final response = await client.functions.invoke(
        'ai_proxy',
        body: {'messages': history, 'sessionId': sessionId},
      );

      // 4. Parse response
      final data = response.data is String
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;

      final aiContent =
          (data['message'] as String?) ??
          'I\'m here for you. Could you tell me more?';

      final aiMsg = ChatMessage.local(role: 'assistant', content: aiContent);

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );
    } on FunctionException catch (e, st) {
      ErrorReporter.captureException(
        e,
        stackTrace: st,
        context: 'chat.edgeFunction',
        extras: {'status': e.status},
      );
      state = state.copyWith(
        isLoading: false,
        error: _friendlyFunctionError(e),
      );
    } catch (e, st) {
      ErrorReporter.captureException(
        e,
        stackTrace: st,
        context: 'chat.sendMessage',
      );
      state = state.copyWith(
        isLoading: false,
        error: 'Connection error. Please check your internet.',
      );
    }
  }

  // ── Utilities ──────────────────────────────────────────────────────────

  /// Clear the current chat and start a new session.
  void clearChat() {
    state = const ChatState();
  }

  /// Map FunctionException to user-friendly messages.
  String _friendlyFunctionError(FunctionException e) {
    final status = e.status;
    if (status == 401) return 'Session expired. Please sign in again.';
    if (status == 429) return 'Too many requests. Please wait a moment.';
    if (status == 502) return 'AI service is temporarily unavailable.';
    return 'Something went wrong. Please try again.';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Provider
// ═══════════════════════════════════════════════════════════════════════════

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
