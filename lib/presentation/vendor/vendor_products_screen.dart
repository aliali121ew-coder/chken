import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../domain/entities/product.dart';
import '../../l10n/app_localizations.dart';
import '../providers/vendor_providers.dart';

class VendorProductsScreen extends ConsumerWidget {
  const VendorProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeAsync = ref.watch(myStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProducts),
        actions: [
          IconButton(
            tooltip: l10n.vendor_inventory,
            icon: const Icon(Icons.history),
            onPressed: () => context.push(AppRoutes.vendorInventory),
          ),
        ],
      ),
      floatingActionButton: storeAsync.maybeWhen(
        data: (store) => store == null
            ? null
            : FloatingActionButton(
                onPressed: () => _showProductForm(context, ref, storeId: store.id),
                child: const Icon(Icons.add),
              ),
        orElse: () => null,
      ),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(l10n.common_error)),
        data: (store) {
          if (store == null) {
            return Center(child: Text(l10n.vendor_noStore));
          }
          final productsAsync = ref.watch(vendorProductsProvider(store.id));
          return productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.common_error),
                  TextButton(
                    onPressed: () => ref.invalidate(vendorProductsProvider(store.id)),
                    child: Text(l10n.common_retry),
                  ),
                ],
              ),
            ),
            data: (products) {
              if (products.isEmpty) {
                return Center(child: Text(l10n.vendor_noProducts));
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(vendorProductsProvider(store.id).future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ProductTile(product: products[index], storeId: store.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product, required this.storeId});

  final Product product;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: product.primaryImageUrl != null ? NetworkImage(product.primaryImageUrl!) : null,
          child: product.primaryImageUrl == null ? const Icon(Icons.inventory_2_outlined) : null,
        ),
        title: Text(product.nameAr),
        subtitle: Text(
          '${product.finalPrice.toStringAsFixed(2)} · ${l10n.common_stock}: ${product.stockQuantity} · '
          '${product.isActive ? l10n.common_active : l10n.common_inactive}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showProductForm(context, ref, storeId: storeId, product: product);
            } else if (value == 'delete') {
              _confirmDelete(context, ref, storeId: storeId, productId: product.id);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text(l10n.common_edit)),
            PopupMenuItem(value: 'delete', child: Text(l10n.common_delete)),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref, {required String storeId, required String productId}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(l10n.vendor_deleteProductConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.common_cancel)),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.common_delete)),
      ],
    ),
  );

  if (confirmed ?? false) {
    await ref.read(vendorControllerProvider.notifier).deleteProduct(storeId, productId);
  }
}

Future<void> _showProductForm(BuildContext context, WidgetRef ref, {required String storeId, Product? product}) async {
  final l10n = AppLocalizations.of(context);
  final nameArController = TextEditingController(text: product?.nameAr ?? '');
  final nameEnController = TextEditingController(text: product?.nameEn ?? '');
  final descriptionController = TextEditingController(text: product?.descriptionAr ?? '');
  final priceController = TextEditingController(text: product != null ? product.basePrice.toString() : '');
  final discountController = TextEditingController(text: '${product?.discountPercentage ?? 0}');
  final stockController = TextEditingController(text: '${product?.stockQuantity ?? 0}');
  final formKey = GlobalKey<FormState>();
  var isActive = product?.isActive ?? true;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      product == null ? l10n.vendor_addProduct : l10n.vendor_editProduct,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameArController,
                      decoration: InputDecoration(labelText: l10n.common_name, border: const OutlineInputBorder()),
                      validator: (value) => value == null || value.trim().isEmpty ? l10n.common_required : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameEnController,
                      decoration: InputDecoration(labelText: l10n.common_nameEn, border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: l10n.common_description, border: const OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: priceController,
                            decoration: InputDecoration(labelText: l10n.common_price, border: const OutlineInputBorder()),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return l10n.common_required;
                              return double.tryParse(value) == null ? l10n.common_required : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: discountController,
                            decoration: InputDecoration(labelText: l10n.common_discount, border: const OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockController,
                      decoration: InputDecoration(labelText: l10n.common_stock, border: const OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.common_active),
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        final controller = ref.read(vendorControllerProvider.notifier);
                        final basePrice = double.parse(priceController.text);
                        final discount = int.tryParse(discountController.text) ?? 0;
                        final stock = int.tryParse(stockController.text) ?? 0;
                        final nameEn = nameEnController.text.trim().isEmpty ? null : nameEnController.text.trim();
                        final description = descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim();

                        final ok = product == null
                            ? await controller.createProduct(
                                storeId: storeId,
                                nameAr: nameArController.text.trim(),
                                nameEn: nameEn,
                                descriptionAr: description,
                                basePrice: basePrice,
                                discountPercentage: discount,
                                stockQuantity: stock,
                                categoryId: product?.categoryId,
                                isActive: isActive,
                              )
                            : await controller.updateProduct(
                                storeId: storeId,
                                productId: product.id,
                                nameAr: nameArController.text.trim(),
                                nameEn: nameEn,
                                descriptionAr: description,
                                basePrice: basePrice,
                                discountPercentage: discount,
                                stockQuantity: stock,
                                categoryId: product.categoryId,
                                isActive: isActive,
                              );
                        if (ok && context.mounted) Navigator.of(context).pop();
                      },
                      child: Text(l10n.common_save),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
