import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inventory_log.dart';
import '../../l10n/app_localizations.dart';
import '../providers/vendor_providers.dart';

/// Returns the localized label for an inventory log `reason` value.
String inventoryReasonLabel(AppLocalizations l10n, String? reason) {
  switch (reason) {
    case 'sale':
      return l10n.vendor_reason_sale;
    case 'restock':
      return l10n.vendor_reason_restock;
    case 'adjustment':
      return l10n.vendor_reason_adjustment;
    case 'return':
      return l10n.vendor_reason_return;
    case 'damage':
      return l10n.vendor_reason_damage;
    default:
      return reason ?? '—';
  }
}

class VendorInventoryScreen extends ConsumerWidget {
  const VendorInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeAsync = ref.watch(myStoreProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vendor_inventory)),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(l10n.common_error)),
        data: (store) {
          if (store == null) {
            return Center(child: Text(l10n.vendor_noStore));
          }
          final logsAsync = ref.watch(inventoryLogsProvider(store.id));
          return logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.common_error),
                  TextButton(
                    onPressed: () => ref.invalidate(inventoryLogsProvider(store.id)),
                    child: Text(l10n.common_retry),
                  ),
                ],
              ),
            ),
            data: (logs) {
              if (logs.isEmpty) {
                return Center(child: Text(l10n.vendor_noInventoryLogs));
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(inventoryLogsProvider(store.id).future),
                child: ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _LogTile(log: logs[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final InventoryLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final positive = log.changeAmount >= 0;
    final color = positive ? Colors.green : theme.colorScheme.error;

    return ListTile(
      title: Text(log.productName ?? '—'),
      subtitle: Text(
        '${inventoryReasonLabel(l10n, log.reason)} · ${_formatDate(log.createdAt)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${positive ? '+' : ''}${log.changeAmount}',
            style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          Text('= ${log.stockAfter}', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
