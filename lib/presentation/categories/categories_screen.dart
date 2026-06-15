import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../domain/entities/category.dart';
import '../../l10n/app_localizations.dart';
import '../providers/catalog_providers.dart';
import '../providers/home_providers.dart';
import '../providers/locale_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_box.dart';

/// Browse all categories and the products within the selected one.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCategories)),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(categoriesProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(child: Text(l10n.common_empty));
          }

          final selectedId = _selectedCategoryId ?? categories.first.id;

          return Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == selectedId;
                    return _CategoryChip(
                      category: category,
                      languageCode: languageCode,
                      selected: isSelected,
                      onSelected: () => setState(() => _selectedCategoryId = category.id),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _CategoryProductsGrid(categoryId: selectedId, languageCode: languageCode),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.languageCode,
    required this.selected,
    required this.onSelected,
  });

  final Category category;
  final String languageCode;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(category.name(languageCode)),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _CategoryProductsGrid extends ConsumerWidget {
  const _CategoryProductsGrid({required this.categoryId, required this.languageCode});

  final String categoryId;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final productsAsync = ref.watch(productsByCategoryProvider(categoryId));

    return productsAsync.when(
      loading: () => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerBox(width: double.infinity, height: double.infinity),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.common_error),
            TextButton(
              onPressed: () => ref.invalidate(productsByCategoryProvider(categoryId)),
              child: Text(l10n.common_retry),
            ),
          ],
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Center(child: Text(l10n.common_empty));
        }
        return MasonryGridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: products.length,
          itemBuilder: (context, index) => ProductCard(product: products[index], languageCode: languageCode),
        );
      },
    );
  }
}
