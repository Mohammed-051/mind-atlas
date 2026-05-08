import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import 'chat_provider.dart';

/// Empathetic AI chat interface with crisis intervention protocol.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize chat session (loads persisted messages or creates new session)
    Future.microtask(() {
      ref.read(chatProvider.notifier).initializeChat();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  /// CRITICAL: Crisis Intervention Protocol
  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;

    final notifier = ref.read(chatProvider.notifier);

    // ── Crisis keyword detection ──────────────────────
    if (notifier.containsCrisisKeyword(text)) {
      notifier.lockChat();
      _textController.clear();
      // Immediately route to emergency screen
      context.push('/emergency');
      return;
    }

    notifier.sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Auto-scroll when new messages arrive
    ref.listen<ChatState>(chatProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
    });

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.mdBorder,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MindMentor',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  chatState.isLoading ? 'Thinking...' : 'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: chatState.isLoading
                        ? AppColors.accent
                        : AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
            },
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'New conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages List ──────────────────────────────
          Expanded(
            child: chatState.messages.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: chatState.messages.length +
                        (chatState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length) {
                        return _TypingIndicator();
                      }
                      final msg = chatState.messages[index];
                      return _ChatBubble(message: msg);
                    },
                  ),
          ),

          // ── Error Banner ─────────────────────────────
          if (chatState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10,
              ),
              color: AppColors.emergency.withValues(alpha: 0.1),
              child: Text(
                chatState.error!,
                style: const TextStyle(
                  color: AppColors.emergency,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // ── Locked Banner ────────────────────────────
          if (chatState.isLocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.emergencyLight,
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    color: AppColors.emergency,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chat locked — crisis resources available',
                      style: TextStyle(
                        color: AppColors.emergency,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/emergency'),
                    child: const Text('Get Help'),
                  ),
                ],
              ),
            ),

          // ── Input Bar ────────────────────────────────
          if (!chatState.isLocked) _buildInputBar(chatState),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatState chatState) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Share what\'s on your mind...',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.lgBorder,
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _handleSubmit,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _handleSubmit(_textController.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: chatState.isLoading
                    ? null
                    : AppColors.primaryGradient,
                color: chatState.isLoading
                    ? AppColors.surfaceVariant
                    : null,
                borderRadius: AppRadius.mdBorder,
              ),
              child: Icon(
                Icons.send_rounded,
                color: chatState.isLoading
                    ? AppColors.textHint
                    : Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.xlBorder,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hi, I\'m MindMentor',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'I\'m here to listen and support you.\n'
              'Share whatever is on your mind.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(label: 'I feel anxious'),
                _SuggestionChip(label: 'Help me relax'),
                _SuggestionChip(label: 'I need to vent'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends ConsumerWidget {
  final String label;
  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(chatProvider.notifier).sendMessage(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: AppRadius.pillBorder,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.smBorder,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                gradient: isUser ? AppColors.primaryGradient : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: AppShadows.soft,
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.smBorder,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: AppShadows.soft,
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.3;
                    final t = (_controller.value + delay) % 1.0;
                    final opacity = 0.3 + 0.7 * (1 - (2 * t - 1).abs());
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                      ),
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
