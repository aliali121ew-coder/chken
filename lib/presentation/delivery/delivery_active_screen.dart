import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order.dart';
import '../../l10n/app_localizations.dart';
import '../orders/orders_screen.dart';
import '../providers/delivery_providers.dart';
import '../providers/locale_provider.dart';

class DeliveryActiveScreen extends ConsumerWidget {
  const DeliveryActiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final availableAsync = ref.watch(availableOrdersProvider);
    final activeAsync = ref.watch(activeOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.delivery_activeOrders)),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.refresh(availableOrdersProvider.future),
            ref.refresh(activeOrdersProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.delivery_myDeliveries, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            activeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text(l10n.common_error),
              data: (orders) {
                if (orders.isEmpty) return Text(l10n.delivery_noActive);
                return Column(
                  children: [
                    for (final order in orders) ...[
                      _DeliveryOrderCard(order: order, isAvailable: false),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(l10n.delivery_available, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            availableAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text(l10n.common_error),
              data: (orders) {
                if (orders.isEmpty) return Text(l10n.common_empty);
                return Column(
                  children: [
                    for (final order in orders) ...[
                      _DeliveryOrderCard(order: order, isAvailable: true),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryOrderCard extends ConsumerWidget {
  const _DeliveryOrderCard({required this.order, required this.isAvailable});

  final Order order;
  final bool isAvailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final isLoading = ref.watch(deliveryControllerProvider).isLoading;
    final next = deliveryNextStatus(order.status);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNumber, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 4),
            Text(order.storeDisplayName(languageCode), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(order.totalAmount.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (isAvailable)
              FilledButton(
                onPressed: isLoading ? null : () => ref.read(deliveryControllerProvider.notifier).acceptOrder(order.id),
                child: Text(l10n.common_accept),
              )
            else if (next != null)
              FilledButton(
                onPressed: isLoading ? null : () => ref.read(deliveryControllerProvider.notifier).updateOrderStatus(order.id, next),
                child: Text('${l10n.common_markAs}: ${orderStatusLabel(l10n, next)}'),
              ),
          ],
        ),
      ),
    );
  }
}
