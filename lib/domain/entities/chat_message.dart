/// Domain entity mirroring a row of the `chat_messages` table.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.storeId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String? senderId;
  final String? receiverId;
  final String? storeId;
  final String? message;
  final bool isRead;
  final DateTime createdAt;
}

/// A lightweight summary of a conversation for the conversations list:
/// the latest message plus the counterpart's identity.
class ChatConversation {
  const ChatConversation({
    required this.conversationId,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.hasUnread,
  });

  final String conversationId;
  final String? otherUserId;
  final String? lastMessage;
  final DateTime lastMessageAt;
  final bool hasUnread;
}
