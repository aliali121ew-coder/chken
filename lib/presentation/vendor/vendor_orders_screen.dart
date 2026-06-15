import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order.dart';
import '../../l10n/app_localizations.dart';
import '../orders/orders_screen.dart';
import '../providers/vendor_providers.dart';

class VendorOrdersScreen extends ConsumerWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeAsync = ref.watch(myStoreProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navOrders)),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(l10n.common_error)),
        data: (store) {
          if (store == null) {
            return Center(child: Text(l10n.vendor_noStore));
          }
          final ordersAsync = ref.watch(vendorOrdersProvider(store.id));
          return ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.common_error),
                  TextButton(
                    onPressed: () => ref.invalidate(vendorOrdersProvider(store.id)),
                    child: Text(l10n.common_retry),
                  ),
                ],
              ),
            ),
            data: (orders) {
              if (orders.isEmpty) {
                return Center(child: Text(l10n.vendor_noOrders));
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(vendorOrdersProvider(store.id).future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _VendorOrderCard(order: orders[index], storeId: store.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VendorOrderCard extends ConsumerWidget {
  const _VendorOrderCard({required this.order, required this.storeId});

  final Order order;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLoading = ref.watch(vendorControllerProvider).isLoading;
    final next = vendorNextStatus(order.status);
    final canCancel = vendorCanCancel(order.status);

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
            const SizedBox(height: 8),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${item.quantity}x ${item.productName}', style: theme.textTheme.bodyMedium),
              ),
            const SizedBox(height: 8),
            Text(order.totalAmount.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (next != null || canCancel) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (next != null)
                    Expanded(
                      child: FilledButton(
                        onPressed: isLoading
                            ? null
                            : () => ref.read(vendorControllerProvider.notifier).updateOrderStatus(storeId, order.id, next),
                        child: Text('${l10n.common_markAs}: ${orderStatusLabel(l10n, next)}'),
                      ),
                    ),
                  if (next != null && canCancel) const SizedBox(width: 8),
                  if (canCancel)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => ref.read(vendorControllerProvider.notifier).updateOrderStatus(storeId, order.id, 'cancelled'),
                        child: Text(orderStatusLabel(l10n, 'cancelled')),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
