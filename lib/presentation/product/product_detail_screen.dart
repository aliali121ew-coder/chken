import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../domain/entities/product.dart';
import '../../l10n/app_localizations.dart';
import '../providers/cart_providers.dart';
import '../providers/catalog_providers.dart';
import '../providers/locale_provider.dart';
import '../providers/price_alert_providers.dart';
import '../widgets/shimmer_box.dart';
import 'reviews_section.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  final _pageController = PageController();
  int _imageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _incrementQuantity(int stock) {
    if (_quantity < stock) setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _addToCart(Product product) {
    ref.read(cartControllerProvider.notifier).addItem(
          productId: product.id,
          storeId: product.storeId,
          quantity: _quantity,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    ref.listen(cartControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      } else if (previous?.isLoading == true && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.product_addToCart)),
        );
      }
    });

    return Scaffold(
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(productByIdProvider(widget.productId)),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (product) {
          final isLoading = ref.watch(cartControllerProvider).isLoading;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        automaticallyImplyLeading: true,
                        title: Text(
                          product.name(languageCode),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _ImageCarousel(
                          images: product.images,
                          pageController: _pageController,
                          currentIndex: _imageIndex,
                          onPageChanged: (index) => setState(() => _imageIndex = index),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name(languageCode),
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    product.finalPrice.toStringAsFixed(2),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (product.hasDiscount) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      product.basePrice.toStringAsFixed(2),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            decoration: TextDecoration.lineThrough,
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(label: Text('-${product.discountPercentage}%')),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.inStock ? l10n.product_inStock : l10n.product_outOfStock,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: product.inStock
                                          ? Theme.of(context).colorScheme.onSurfaceVariant
                                          : Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              _PriceAlertButton(product: product),
                              if (product.tags.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: product.tags.map((tag) => Chip(label: Text(tag))).toList(),
                                ),
                              ],
                              if (product.description(languageCode)?.isNotEmpty == true) ...[
                                const SizedBox(height: 16),
                                Text(l10n.product_description, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Text(product.description(languageCode)!),
                              ],
                              const SizedBox(height: 24),
                              ReviewsSection(productId: product.id, storeId: product.storeId),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (product.inStock) ...[
                          IconButton.outlined(
                            onPressed: _decrementQuantity,
                            icon: const Icon(Icons.remove),
                          ),
                          SizedBox(
                            width: 48,
                            child: Text(
                              '$_quantity',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton.outlined(
                            onPressed: () => _incrementQuantity(product.stockQuantity),
                            icon: const Icon(Icons.add),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: FilledButton(
                            onPressed: (product.inStock && !isLoading) ? () => _addToCart(product) : null,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(l10n.product_addToCart),
                          ),
                        ),
                      ],
                    ),
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

/// A bell toggle that registers/clears a price-drop or back-in-stock alert
/// for the given product, depending on its current stock.
class _PriceAlertButton extends ConsumerWidget {
  const _PriceAlertButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alertAsync = ref.watch(productAlertProvider(product.id));
    final isLoading = ref.watch(priceAlertControllerProvider).isLoading;
    final alertType = product.inStock ? 'price_drop' : 'back_in_stock';
    final label = product.inStock ? l10n.product_notifyPriceDrop : l10n.product_notifyBackInStock;

    return alertAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (existing) {
        final active = existing != null;
        return OutlinedButton.icon(
          onPressed: isLoading
              ? null
              : () async {
                  final ok = await ref.read(priceAlertControllerProvider.notifier).toggleAlert(
                        productId: product.id,
                        alertType: alertType,
                        targetPrice: product.inStock ? product.finalPrice : null,
                        existing: existing,
                      );
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(active ? l10n.product_alertRemoved : l10n.product_alertSet)),
                    );
                  }
                },
          icon: Icon(active ? Icons.notifications_active : Icons.notifications_none, size: 18),
          label: Text(active ? l10n.product_alertSet : label),
        );
      },
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({
    required this.images,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> images;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.image_outlined, size: 48),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (context, index) => CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => const ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 0),
              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined),
            ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AnimatedSmoothIndicator(
              activeIndex: currentIndex,
              count: images.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
