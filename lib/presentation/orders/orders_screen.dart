import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../domain/entities/order.dart';
import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/order_providers.dart';

/// Returns the localized label for an order's `status` column value.
String orderStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'pending':
      return l10n.orders_status_pending;
    case 'confirmed':
      return l10n.orders_status_confirmed;
    case 'preparing':
      return l10n.orders_status_preparing;
    case 'ready':
      return l10n.orders_status_ready;
    case 'picked_up':
      return l10n.orders_status_pickedUp;
    case 'on_way':
      return l10n.orders_status_onWay;
    case 'delivered':
      return l10n.orders_status_delivered;
    case 'cancelled':
      return l10n.orders_status_cancelled;
    case 'refunded':
      return l10n.orders_status_refunded;
    default:
      return status;
  }
}

/// Returns the next status a vendor can advance an order to, or `null`
/// if the order has reached a vendor-controlled terminal state.
String? vendorNextStatus(String status) {
  switch (status) {
    case 'pending':
      return 'confirmed';
    case 'confirmed':
      return 'preparing';
    case 'preparing':
      return 'ready';
    default:
      return null;
  }
}

/// Whether a vendor can still cancel an order in [status].
bool vendorCanCancel(String status) {
  return status == 'pending' || status == 'confirmed' || status == 'preparing';
}

/// Returns the next status a delivery agent can advance an assigned order
/// to, or `null` if the order has reached a terminal state.
String? deliveryNextStatus(String status) {
  switch (status) {
    case 'picked_up':
      return 'on_way';
    case 'on_way':
      return 'delivered';
    default:
      return null;
  }
}

Color orderStatusColor(BuildContext context, String status) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case 'delivered':
      return Colors.green;
    case 'cancelled':
    case 'refunded':
      return colorScheme.error;
    case 'pending':
      return Colors.orange;
    default:
      return colorScheme.primary;
  }
}

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orders_title)),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(ordersProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(child: Text(l10n.orders_empty));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(ordersProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OrderTile(order: orders[index], languageCode: languageCode),
            ),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order, required this.languageCode});

  final Order order;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => context.push(AppRoutes.orderDetailPath(order.id)),
        title: Text(order.storeDisplayName(languageCode)),
        subtitle: Text('${order.orderNumber} · ${_formatDate(order.createdAt)}'),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
