import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../domain/entities/chat_message.dart';
import '../../l10n/app_localizations.dart';
import '../providers/chat_providers.dart';
import 'chat_screen.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chat_conversations)),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(conversationsProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(child: Text(l10n.chat_noConversations));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(conversationsProvider.future),
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => _ConversationTile(conversation: conversations[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final ChatConversation conversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(
        conversation.lastMessage ?? '—',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: conversation.hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(_formatTime(conversation.lastMessageAt), style: theme.textTheme.bodySmall),
      trailing: conversation.hasUnread
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
            )
          : null,
      onTap: conversation.otherUserId == null
          ? null
          : () => context.push(
                AppRoutes.chatPath(conversation.conversationId),
                extra: ChatArgs(receiverId: conversation.otherUserId!),
              ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
