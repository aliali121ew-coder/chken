import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order.dart';
import '../../l10n/app_localizations.dart';
import '../orders/orders_screen.dart';
import '../providers/delivery_providers.dart';
import '../providers/locale_provider.dart';

class DeliveryHistoryScreen extends ConsumerWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final historyAsync = ref.watch(deliveryHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.delivery_orderHistory)),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(deliveryHistoryProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(child: Text(l10n.delivery_noHistory));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(deliveryHistoryProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _HistoryTile(order: orders[index], languageCode: languageCode),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.order, required this.languageCode});

  final Order order;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(order.storeDisplayName(languageCode)),
        subtitle: Text(order.orderNumber),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(order.totalAmount.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: orderStatusColor(context, order.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                orderStatusLabel(l10n, order.status),
                style: theme.textTheme.labelSmall?.copyWith(color: orderStatusColor(context, order.status)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
