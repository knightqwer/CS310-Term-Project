class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool isMe;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    this.isMe = false,
  });
}
