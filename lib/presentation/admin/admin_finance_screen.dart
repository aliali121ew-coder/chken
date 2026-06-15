import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/admin_providers.dart';

class AdminFinanceScreen extends ConsumerWidget {
  const AdminFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final statsAsync = ref.watch(adminStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.common_error),
            TextButton(
              onPressed: () => ref.invalidate(adminStatsProvider),
              child: Text(l10n.common_retry),
            ),
          ],
        ),
      ),
      data: (stats) => RefreshIndicator(
        onRefresh: () => ref.refresh(adminStatsProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.admin_financeOverview, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(l10n.vendor_totalRevenue),
                trailing: Text(
                  stats.totalRevenue.toStringAsFixed(2),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(l10n.vendor_totalOrders),
                trailing: Text(
                  '${stats.totalOrders}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
