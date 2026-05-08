/// Immutable data model for chat messages from Supabase `messages` table.
class ChatMessage {
  final String id;
  final String? sessionId;
  final String? userId;
  final String role; // 'user', 'assistant', or 'system'
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    this.sessionId,
    this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  /// Construct from Supabase row JSON.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sessionId: json['session_id'] as String?,
      userId: json['user_id'] as String?,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Serialize to JSON for Supabase insert.
  Map<String, dynamic> toJson() {
    return {
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      'role': role,
      'content': content,
    };
  }

  /// Create a lightweight client-side message (before DB persistence).
  factory ChatMessage.local({
    required String role,
    required String content,
  }) {
    return ChatMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      role: role,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  /// Convert to the format expected by the Edge Function payload.
  Map<String, String> toApiPayload() {
    return {
      'role': role,
      'content': content,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? role,
    String? content,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
