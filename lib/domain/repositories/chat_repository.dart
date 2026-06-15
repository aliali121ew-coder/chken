import '../entities/chat_message.dart';

/// Direct messaging between users (e.g. customer ↔ store/vendor).
abstract class ChatRepository {
  /// Distinct conversations the signed-in user participates in, most
  /// recently active first.
  Future<List<ChatConversation>> getConversations();

  /// A realtime stream of all messages in [conversationId], ordered oldest
  /// to newest.
  Stream<List<ChatMessage>> watchMessages(String conversationId);

  Future<void> sendMessage({
    required String conversationId,
    required String receiverId,
    String? storeId,
    required String message,
  });

  /// Marks messages in [conversationId] addressed to the signed-in user
  /// as read.
  Future<void> markConversationRead(String conversationId);
}
