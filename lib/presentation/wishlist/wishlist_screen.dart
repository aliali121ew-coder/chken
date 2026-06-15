import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/wishlist_providers.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final productsAsync = ref.watch(wishlistProductsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wishlist_title)),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(wishlistProductsProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return Center(child: Text(l10n.wishlist_empty));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(wishlistProductsProvider.future),
            child: MasonryGridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: products.length,
              itemBuilder: (context, index) => ProductCard(product: products[index], languageCode: languageCode),
            ),
          );
        },
      ),
    );
  }
}
