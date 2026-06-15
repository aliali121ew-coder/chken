import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../l10n/app_localizations.dart';
import '../providers/catalog_providers.dart';
import '../providers/locale_provider.dart';
import '../widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: l10n.search_hint,
            border: InputBorder.none,
          ),
        ),
      ),
      body: _buildBody(l10n, languageCode),
    );
  }

  Widget _buildBody(AppLocalizations l10n, String languageCode) {
    if (_query.length < 2) {
      return Center(child: Text(l10n.search_minChars));
    }

    final resultsAsync = ref.watch(searchProductsProvider(_query));

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.common_error),
            TextButton(
              onPressed: () => ref.invalidate(searchProductsProvider(_query)),
              child: Text(l10n.common_retry),
            ),
          ],
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Center(child: Text(l10n.search_noResults));
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
