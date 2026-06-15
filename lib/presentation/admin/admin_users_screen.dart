import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../providers/admin_providers.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final usersAsync = ref.watch(adminUsersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.common_error),
            TextButton(
              onPressed: () => ref.invalidate(adminUsersProvider),
              child: Text(l10n.common_retry),
            ),
          ],
        ),
      ),
      data: (users) {
        if (users.isEmpty) {
          return Center(child: Text(l10n.admin_noUsers));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminUsersProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _UserTile(user: users[index]),
          ),
        );
      },
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLoading = ref.watch(adminControllerProvider).isLoading;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null ? const Icon(Icons.person_outline) : null,
        ),
        title: Text(user.fullName?.isNotEmpty ?? false ? user.fullName! : l10n.profile_guest),
        subtitle: Text(
          '${user.role.name} · ${user.isActive ? l10n.common_active : l10n.common_inactive}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: TextButton(
          onPressed: isLoading ? null : () => ref.read(adminControllerProvider.notifier).setUserActive(user.id, !user.isActive),
          child: Text(user.isActive ? l10n.admin_suspend : l10n.admin_activate),
        ),
      ),
    );
  }
}
