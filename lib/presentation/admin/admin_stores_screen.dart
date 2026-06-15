import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/store.dart';
import '../../l10n/app_localizations.dart';
import '../providers/admin_providers.dart';
import '../providers/locale_provider.dart';

class AdminStoresScreen extends ConsumerWidget {
  const AdminStoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pendingAsync = ref.watch(pendingStoresProvider);
    final allAsync = ref.watch(allStoresProvider);
    final languageCode = ref.watch(localeProvider).languageCode;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.refresh(pendingStoresProvider.future),
          ref.refresh(allStoresProvider.future),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.admin_pendingStores, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          pendingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(l10n.common_error),
            data: (stores) {
              if (stores.isEmpty) return Text(l10n.admin_noPendingStores);
              return Column(
                children: [
                  for (final store in stores) ...[
                    _PendingStoreCard(store: store, languageCode: languageCode),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(l10n.admin_allStores, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          allAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(l10n.common_error),
            data: (stores) {
              if (stores.isEmpty) return Text(l10n.common_empty);
              return Column(
                children: [
                  for (final store in stores) ...[
                    _AllStoreTile(store: store, languageCode: languageCode),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PendingStoreCard extends ConsumerWidget {
  const _PendingStoreCard({required this.store, required this.languageCode});

  final Store store;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLoading = ref.watch(adminControllerProvider).isLoading;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.displayName(languageCode), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (store.category != null) ...[
              const SizedBox(height: 4),
              Text(store.category!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading ? null : () => ref.read(adminControllerProvider.notifier).setStoreApproval(store.id, true),
                    child: Text(l10n.admin_approve),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => ref.read(adminControllerProvider.notifier).setStoreActive(store.id, false),
                    child: Text(l10n.admin_reject),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AllStoreTile extends ConsumerWidget {
  const _AllStoreTile({required this.store, required this.languageCode});

  final Store store;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLoading = ref.watch(adminControllerProvider).isLoading;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(store.displayName(languageCode)),
        subtitle: Text(
          '${store.isApproved ? l10n.admin_approve : l10n.admin_pendingStores} · '
          '${store.isActive ? l10n.common_active : l10n.common_inactive}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: TextButton(
          onPressed: isLoading ? null : () => ref.read(adminControllerProvider.notifier).setStoreActive(store.id, !store.isActive),
          child: Text(store.isActive ? l10n.admin_deactivate : l10n.admin_activate),
        ),
      ),
    );
  }
}
