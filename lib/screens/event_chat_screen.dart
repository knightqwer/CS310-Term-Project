import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';

class EventChatScreen extends StatefulWidget {
  const EventChatScreen({super.key});

  @override
  State<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends State<EventChatScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final String eventName = 'Study Session';
  final int memberCount = 7;

  final List<ChatMessage> messages = [
    const ChatMessage(sender: 'User A', text: 'Hey, looking forward to this event!', time: '14:14'),
    const ChatMessage(sender: 'User B', text: 'Me too!', time: '14:15'),
    const ChatMessage(sender: 'You', text: 'You guys are all welcome', time: '14:16', isMe: true),
    const ChatMessage(sender: 'User B', text: 'Where are you located?', time: '14:17'),
    const ChatMessage(sender: 'User C', text: 'Is registration still open?', time: '14:18'),
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void handleSend() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final now = TimeOfDay.now();
      messages.add(ChatMessage(
        sender: 'You',
        text: text,
        time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        isMe: true,
      ));
      messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eventName, style: AppTextStyles.title.copyWith(fontSize: 18)),
            Text('$memberCount members', style: AppTextStyles.bodySecondary.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: AppPaddings.chatList,
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildBubble(messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: AppPaddings.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => handleSend(),
                      decoration: InputDecoration(
                        hintText: AppStrings.chatHint,
                        hintStyle: TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppPaddings.md, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppPaddings.sm),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.onPrimary),
                      onPressed: handleSend,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final align = msg.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = msg.isMe ? AppColors.primary : AppColors.surface;
    final textColor = msg.isMe ? AppColors.onPrimary : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isMe)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: AppPaddings.sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.person, color: AppColors.textPrimary, size: 20),
            ),
          Flexible(
            child: Align(
              alignment: align,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!msg.isMe)
                      Text(
                        msg.sender,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (!msg.isMe) const SizedBox(height: 2),
                    Text(msg.text, style: TextStyle(color: textColor, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      msg.time,
                      style: TextStyle(
                        color: msg.isMe ? AppColors.border : AppColors.textHint,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
