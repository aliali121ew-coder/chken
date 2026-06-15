import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

/// Supabase-backed implementation of [ChatRepository], using Realtime for
/// the live message stream.
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._client);

  final SupabaseClient _client;

  ChatMessage _fromJson(Map<String, dynamic> row) {
    return ChatMessage(
      id: row['id'] as String,
      conversationId: row['conversation_id'] as String,
      senderId: row['sender_id'] as String?,
      receiverId: row['receiver_id'] as String?,
      storeId: row['store_id'] as String?,
      message: row['message'] as String?,
      isRead: row['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  @override
  Future<List<ChatConversation>> getConversations() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.chatMessages)
        .select()
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    final byConversation = <String, ChatConversation>{};
    for (final row in rows) {
      final message = _fromJson(row);
      final existing = byConversation[message.conversationId];
      final otherUserId = message.senderId == userId ? message.receiverId : message.senderId;
      final isIncomingUnread = message.receiverId == userId && !message.isRead;

      if (existing == null) {
        // Rows are newest-first, so the first seen row is the latest message.
        byConversation[message.conversationId] = ChatConversation(
          conversationId: message.conversationId,
          otherUserId: otherUserId,
          lastMessage: message.message,
          lastMessageAt: message.createdAt,
          hasUnread: isIncomingUnread,
        );
      } else if (isIncomingUnread && !existing.hasUnread) {
        byConversation[message.conversationId] = ChatConversation(
          conversationId: existing.conversationId,
          otherUserId: existing.otherUserId,
          lastMessage: existing.lastMessage,
          lastMessageAt: existing.lastMessageAt,
          hasUnread: true,
        );
      }
    }

    return byConversation.values.toList();
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _client
        .from(SupabaseTables.chatMessages)
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((rows) => rows.map(_fromJson).toList());
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String receiverId,
    String? storeId,
    required String message,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from(SupabaseTables.chatMessages).insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'receiver_id': receiverId,
      'store_id': storeId,
      'message': message,
    });
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from(SupabaseTables.chatMessages)
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .eq('receiver_id', userId)
        .eq('is_read', false);
  }
}
