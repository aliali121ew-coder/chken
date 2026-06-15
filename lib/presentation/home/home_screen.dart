import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../providers/home_providers.dart';
import '../providers/locale_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_box.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(categoriesProvider);
    ref.invalidate(featuredProductsProvider);
    ref.invalidate(bestSellersProvider);
    ref.invalidate(nearbyStoresProvider);
    await Future.wait([
      ref.read(categoriesProvider.future),
      ref.read(featuredProductsProvider.future),
      ref.read(bestSellersProvider.future),
      ref.read(nearbyStoresProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final profile = ref.watch(currentProfileProvider).value;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _onRefresh(ref),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile?.fullName?.isNotEmpty == true
                              ? '${l10n.appName} · ${profile!.fullName}'
                              : l10n.appName,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () => context.push(AppRoutes.notifications),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchField(
                    hintText: l10n.home_searchPlaceholder,
                    onTap: () => context.push(AppRoutes.search),
                  ),
                ),
              ),
              _SectionHeader(title: l10n.home_categories),
              SliverToBoxAdapter(
                child: _CategoriesRow(languageCode: languageCode),
              ),
              _SectionHeader(title: l10n.home_featured),
              SliverToBoxAdapter(
                child: _ProductsRow(
                  provider: featuredProductsProvider,
                  languageCode: languageCode,
                ),
              ),
              _SectionHeader(title: l10n.home_bestSellers),
              SliverToBoxAdapter(
                child: _ProductsRow(
                  provider: bestSellersProvider,
                  languageCode: languageCode,
                ),
              ),
              _SectionHeader(title: l10n.home_nearbyStores),
              SliverToBoxAdapter(
                child: _StoresRow(languageCode: languageCode),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hintText, required this.onTap});

  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: hintText,
          enabled: false,
        ),
        child: const SizedBox(height: 24),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(
              l10n.common_seeAll,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesRow extends ConsumerWidget {
  const _CategoriesRow({required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return SizedBox(
      height: 92,
      child: categories.when(
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 6,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) => Column(
            children: [
              const ShimmerBox(width: 56, height: 56, borderRadius: 28),
              const SizedBox(height: 8),
              ShimmerBox(width: 48, height: 12, borderRadius: 4),
            ],
          ),
        ),
        error: (error, stackTrace) => _InlineError(onRetry: () => ref.invalidate(categoriesProvider)),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).common_empty));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _CategoryTile(category: items[index], languageCode: languageCode),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.languageCode});

  final Category category;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            backgroundImage: category.iconUrl != null ? CachedNetworkImageProvider(category.iconUrl!) : null,
            child: category.iconUrl == null ? const Icon(Icons.category_outlined) : null,
          ),
          const SizedBox(height: 8),
          Text(
            category.name(languageCode),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProductsRow extends ConsumerWidget {
  const _ProductsRow({required this.provider, required this.languageCode});

  final FutureProvider<List<Product>> provider;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(provider);

    return SizedBox(
      height: 220,
      child: products.when(
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) => const ShimmerBox(width: 150, height: 220),
        ),
        error: (error, stackTrace) => _InlineError(onRetry: () => ref.invalidate(provider)),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).common_empty));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 150,
              child: ProductCard(product: items[index], languageCode: languageCode),
            ),
          );
        },
      ),
    );
  }
}

class _StoresRow extends ConsumerWidget {
  const _StoresRow({required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(nearbyStoresProvider);

    return SizedBox(
      height: 150,
      child: stores.when(
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) => const ShimmerBox(width: 180, height: 150),
        ),
        error: (error, stackTrace) => _InlineError(onRetry: () => ref.invalidate(nearbyStoresProvider)),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).common_empty));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _StoreCard(store: items[index], languageCode: languageCode),
          );
        },
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.languageCode});

  final Store store;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push(AppRoutes.storePath(store.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
                width: double.infinity,
                child: store.bannerUrl != null
                    ? CachedNetworkImage(
                        imageUrl: store.bannerUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerBox(width: double.infinity, height: 80, borderRadius: 0),
                        errorWidget: (context, url, error) => Container(color: theme.colorScheme.surfaceContainerHighest),
                      )
                    : Container(color: theme.colorScheme.surfaceContainerHighest),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.displayName(languageCode),
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(store.rating.toStringAsFixed(1), style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.common_error),
          TextButton(onPressed: onRetry, child: Text(l10n.common_retry)),
        ],
      ),
    );
  }
}
