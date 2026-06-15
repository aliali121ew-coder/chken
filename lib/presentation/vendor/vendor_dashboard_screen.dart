import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/vendor_providers.dart';

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final storeAsync = ref.watch(myStoreProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vendor_dashboard)),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(myStoreProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (store) {
          if (store == null) {
            return Center(child: Text(l10n.vendor_noStore));
          }
          final statsAsync = ref.watch(vendorStatsProvider(store.id));
          return RefreshIndicator(
            onRefresh: () => ref.refresh(vendorStatsProvider(store.id).future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(store.displayName(languageCode), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                statsAsync.when(
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                  error: (error, stackTrace) => Text(l10n.common_error),
                  data: (stats) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _StatCard(label: l10n.vendor_totalOrders, value: '${stats.totalOrders}')),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(label: l10n.vendor_pendingOrders, value: '${stats.pendingOrders}')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StatCard(label: l10n.vendor_totalRevenue, value: stats.totalRevenue.toStringAsFixed(2)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
