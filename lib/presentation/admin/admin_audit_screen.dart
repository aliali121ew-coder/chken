import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/admin_repository.dart';
import '../../l10n/app_localizations.dart';
import '../providers/admin_providers.dart';

class AdminAuditScreen extends ConsumerWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logsAsync = ref.watch(adminAuditLogsProvider);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.common_error),
            TextButton(
              onPressed: () => ref.invalidate(adminAuditLogsProvider),
              child: Text(l10n.common_retry),
            ),
          ],
        ),
      ),
      data: (logs) {
        if (logs.isEmpty) {
          return Center(child: Text(l10n.admin_noAuditLogs));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminAuditLogsProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _AuditTile(entry: logs[index]),
          ),
        );
      },
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.entry});

  final AuditLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const Icon(Icons.fact_check_outlined),
      title: Text(entry.action),
      subtitle: entry.tableName != null ? Text(entry.tableName!, style: theme.textTheme.bodySmall) : null,
      trailing: Text(_formatDate(entry.createdAt), style: theme.textTheme.bodySmall),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
