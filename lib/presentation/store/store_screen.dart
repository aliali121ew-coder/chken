import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../core/theme/store_theme.dart';
import '../../domain/entities/store.dart';
import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/store_providers.dart';
import '../providers/store_theme_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_box.dart';

/// Store storefront: banner/logo, info and the store's products.
///
/// While visible, applies the store's [StoreTheme] to the whole app
/// (cleared again when this screen is disposed).
class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({required this.storeId, super.key});

  final String storeId;

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  @override
  void dispose() {
    ref.read(storeThemeProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final storeAsync = ref.watch(storeByIdProvider(widget.storeId));

    ref.listen(storeByIdProvider(widget.storeId), (previous, next) {
      final store = next.value;
      if (store == null) return;
      final theme = StoreTheme.fromHex(
        gradientStart: store.gradientStart,
        gradientEnd: store.gradientEnd,
        primaryColor: store.primaryColor,
        secondaryColor: store.secondaryColor,
      );
      ref.read(storeThemeProvider.notifier).enter(theme);
    });

    return Scaffold(
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(storeByIdProvider(widget.storeId)),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (store) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 180,
                title: Text(store.displayName(languageCode)),
                flexibleSpace: FlexibleSpaceBar(
                  background: store.bannerUrl != null
                      ? CachedNetworkImage(
                          imageUrl: store.bannerUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 0),
                          errorWidget: (context, url, error) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                        )
                      : Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: _StoreInfo(store: store, languageCode: languageCode),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Text(l10n.store_products, style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: _StoreProductsGrid(storeId: widget.storeId, languageCode: languageCode),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StoreInfo extends StatelessWidget {
  const _StoreInfo({required this.store, required this.languageCode});

  final Store store;
  final String languageCode;

  String? _description() {
    final descriptionEn = store.descriptionEn;
    if (languageCode == 'en' && descriptionEn != null && descriptionEn.isNotEmpty) {
      return descriptionEn;
    }
    return store.description;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final description = _description();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 64,
            height: 64,
            child: store.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: store.logoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ShimmerBox(width: 64, height: 64, borderRadius: 12),
                    errorWidget: (context, url, error) => const Icon(Icons.storefront_outlined),
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.storefront_outlined),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.displayName(languageCode), style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text('${store.rating.toStringAsFixed(1)} (${store.totalReviews})', style: theme.textTheme.bodyMedium),
                ],
              ),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${l10n.cart_deliveryFee}: ${store.deliveryFee.toStringAsFixed(2)} · ${l10n.store_minOrder}: ${store.minOrderAmount.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoreProductsGrid extends ConsumerWidget {
  const _StoreProductsGrid({required this.storeId, required this.languageCode});

  final String storeId;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final productsAsync = ref.watch(storeProductsProvider(storeId));

    return productsAsync.when(
      loading: () => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ShimmerBox(width: double.infinity, height: double.infinity),
          childCount: 6,
        ),
      ),
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(storeProductsProvider(storeId)),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return SliverToBoxAdapter(child: Center(child: Text(l10n.common_empty)));
        }
        return SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childCount: products.length,
          itemBuilder: (context, index) => ProductCard(product: products[index], languageCode: languageCode),
        );
      },
    );
  }
}
