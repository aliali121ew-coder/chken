import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../domain/entities/cart_item.dart';
import '../../l10n/app_localizations.dart';
import '../providers/cart_providers.dart';
import '../providers/locale_provider.dart';
import '../widgets/shimmer_box.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final cartAsync = ref.watch(cartItemsProvider);

    ref.listen(cartControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cart_title)),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(cartItemsProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.cart_empty));
          }

          final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _CartItemTile(item: items[index], languageCode: languageCode),
                ),
              ),
              _CartSummary(subtotal: subtotal),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item, required this.languageCode});

  final CartItem item;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(cartControllerProvider).isLoading;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(cartControllerProvider.notifier).removeItem(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: item.product.primaryImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: item.product.primaryImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerBox(width: 64, height: 64, borderRadius: 8),
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
                    Text(
                      item.product.name(languageCode),
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.storeDisplayName(languageCode),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.lineTotal.toStringAsFixed(2),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: isLoading || item.quantity >= item.product.stockQuantity
                        ? null
                        : () => ref.read(cartControllerProvider.notifier).updateQuantity(item.id, item.quantity + 1),
                  ),
                  Text('${item.quantity}', style: theme.textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (item.quantity > 1) {
                              ref.read(cartControllerProvider.notifier).updateQuantity(item.id, item.quantity - 1);
                            } else {
                              ref.read(cartControllerProvider.notifier).removeItem(item.id);
                            }
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.cart_subtotal, style: theme.textTheme.bodyMedium),
                Text(subtotal.toStringAsFixed(2), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push(AppRoutes.checkout),
                child: Text(l10n.cart_checkout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
