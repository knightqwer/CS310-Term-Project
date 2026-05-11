import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';

class EventChatScreen extends StatefulWidget {
  final Event event;

  const EventChatScreen({super.key, required this.event});

  @override
  State<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends State<EventChatScreen> {
  final _messageService = MessageService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to send a message')),
      );
      return;
    }

    setState(() => _isSending = true);
    final payload = Message(
      id: '',
      senderUid: user.uid,
      senderName: user.displayName ?? user.email ?? 'Anonymous',
      text: text,
    ).toMap();

    try {
      await _messageService.sendMessage(widget.event.id, payload);
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberCount = widget.event.attendeeUids.length;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.title, style: AppTextStyles.title.copyWith(fontSize: 18)),
            Text(
              '$memberCount member${memberCount == 1 ? '' : 's'}',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageService.messagesStream(widget.event.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Could not load messages',
                      style: AppTextStyles.bodySecondary,
                    ),
                  );
                }
                final messages = snapshot.data ?? const [];
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppPaddings.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 56, color: AppColors.textSecondary),
                          const SizedBox(height: AppPaddings.md),
                          Text('No messages yet', style: AppTextStyles.title),
                          const SizedBox(height: AppPaddings.sm),
                          Text(
                            'Be the first to say hi!',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  padding: AppPaddings.chatList,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildBubble(msg, isMe: msg.senderUid == currentUid);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: AppPaddings.sm),
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
                      controller: _messageController,
                      enabled: !_isSending,
                      style: TextStyle(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: AppStrings.chatHint,
                        hintStyle: TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppPaddings.md, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppPaddings.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : Icon(Icons.send, color: AppColors.onPrimary),
                      onPressed: _isSending ? null : _handleSend,
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

  Widget _buildBubble(Message msg, {required bool isMe}) {
    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe ? AppColors.primary : AppColors.surface;
    final textColor = isMe ? AppColors.onPrimary : AppColors.textPrimary;
    final timeLabel = msg.createdAt != null
        ? DateFormat('HH:mm').format(msg.createdAt!)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: AppPaddings.sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(Icons.person,
                  color: AppColors.textPrimary, size: 20),
            ),
          Flexible(
            child: Align(
              alignment: align,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    if (!isMe)
                      Text(
                        msg.senderName,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (!isMe) const SizedBox(height: 2),
                    Text(msg.text,
                        style: TextStyle(color: textColor, fontSize: 14)),
                    if (timeLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          color: isMe ? AppColors.border : AppColors.textHint,
                          fontSize: 10,
                        ),
                      ),
                    ],
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
