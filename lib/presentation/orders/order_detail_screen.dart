import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order.dart';
import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/order_providers.dart';
import '../widgets/shimmer_box.dart';
import 'orders_screen.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orders_orderDetails)),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(orderByIdProvider(orderId)),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (order) => _OrderDetailBody(order: order, languageCode: languageCode),
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order, required this.languageCode});

  final Order order;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.orderNumber, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: orderStatusColor(context, order.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        orderStatusLabel(l10n, order.status),
                        style: theme.textTheme.labelMedium?.copyWith(color: orderStatusColor(context, order.status)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.storeDisplayName(languageCode),
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.orders_items, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...order.items.map((item) => _OrderItemTile(item: item)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryRow(label: l10n.cart_subtotal, value: order.subtotal),
                _SummaryRow(label: l10n.cart_deliveryFee, value: order.deliveryFee),
                if (order.discountAmount > 0) _SummaryRow(label: l10n.cart_discount, value: -order.discountAmount),
                const Divider(),
                _SummaryRow(label: l10n.cart_total, value: order.totalAmount, emphasize: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: item.productImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.productImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerBox(width: 56, height: 56, borderRadius: 8),
                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined),
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_outlined),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '${item.quantity} x ${item.unitPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(item.subtotal.toStringAsFixed(2), style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasize
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value.toStringAsFixed(2), style: style),
        ],
      ),
    );
  }
}
