import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../domain/entities/product.dart';
import '../../l10n/app_localizations.dart';
import '../providers/wishlist_providers.dart';
import 'shimmer_box.dart';

/// Product tile used in horizontal lists and grids (Home, Categories,
/// Search). Tapping navigates to the product detail screen.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, required this.languageCode});

  final Product product;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isWishlisted = ref.watch(wishlistProductIdsProvider).value?.contains(product.id) ?? false;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push(AppRoutes.productPath(product.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: product.primaryImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.primaryImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 0),
                          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image_outlined),
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: _WishlistButton(productId: product.id, isWishlisted: isWishlisted),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name(languageCode),
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        product.finalPrice.toStringAsFixed(2),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          product.basePrice.toStringAsFixed(2),
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!product.inStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.product_outOfStock,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistButton extends ConsumerWidget {
  const _WishlistButton({required this.productId, required this.isWishlisted});

  final String productId;
  final bool isWishlisted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(wishlistControllerProvider).isLoading;

    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isLoading ? null : () => ref.read(wishlistControllerProvider.notifier).toggle(productId),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isWishlisted ? Colors.redAccent : Colors.white,
          ),
        ),
      ),
    );
  }
}
