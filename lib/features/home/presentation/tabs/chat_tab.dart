import 'package:ai_personal_fitness_coach/features/home/providers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_repository.dart';
import '../../domain/models/chat_message.dart';
import '../widgets/chat_bubble.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  late final TextEditingController _messageController;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String message = _messageController.text.trim();

    if (message.isEmpty) return;

    final ApiRepository? apiRepository = ref.watch(apiRepositoryProvider);

    if (apiRepository == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Not authenticated")));
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(role: "user", content: message, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final Map<String, dynamic> response = await apiRepository.sendChatMessage(
        message,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            role: "assistant",
            content: response["message"],
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error $error")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64.0,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        "Start chatting with your AI coach!",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final ChatMessage message = _messages[index];
                    return ChatBubble(message: message);
                  },
                ),
        ),

        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const SizedBox(width: 16.0),
                const CircularProgressIndicator(strokeWidth: 2.0),
                const SizedBox(width: 12.0),
                Text(
                  "Coach is typing...",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10.0,
                offset: Offset(0.0, -2.0),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: (_) => _sendMessage(),
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: "Ask your coach...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8.0),
                FilledButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16.0),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
