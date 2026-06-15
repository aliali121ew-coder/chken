import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(supabaseClientProvider));
});

final conversationsProvider = FutureProvider<List<ChatConversation>>((ref) {
  return ref.watch(chatRepositoryProvider).getConversations();
});

/// Live stream of messages for a single conversation.
final conversationMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).watchMessages(conversationId);
});

/// Drives sending messages and marking a conversation read.
class ChatController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> sendMessage({
    required String conversationId,
    required String receiverId,
    String? storeId,
    required String message,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: conversationId,
            receiverId: receiverId,
            storeId: storeId,
            message: message,
          );
    });
    return !state.hasError;
  }

  Future<void> markRead(String conversationId) async {
    await ref.read(chatRepositoryProvider).markConversationRead(conversationId);
    ref.invalidate(conversationsProvider);
  }
}

final chatControllerProvider = AsyncNotifierProvider<ChatController, void>(ChatController.new);
