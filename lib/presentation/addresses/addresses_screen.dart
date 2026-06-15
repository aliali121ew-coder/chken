import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/address.dart';
import '../../l10n/app_localizations.dart';
import '../providers/address_providers.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final addressesAsync = ref.watch(addressesProvider);

    ref.listen(addressControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addresses_title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(addressesProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(child: Text(l10n.addresses_empty));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _AddressTile(address: addresses[index]),
          );
        },
      ),
    );
  }
}

class _AddressTile extends ConsumerWidget {
  const _AddressTile({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLoading = ref.watch(addressControllerProvider).isLoading;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Row(
          children: [
            Text(address.label),
            if (address.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.addresses_default,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(address.city != null ? '${address.fullAddress}, ${address.city}' : address.fullAddress),
        trailing: PopupMenuButton<String>(
          enabled: !isLoading,
          onSelected: (value) {
            final controller = ref.read(addressControllerProvider.notifier);
            if (value == 'default') {
              controller.setDefaultAddress(address.id);
            } else if (value == 'delete') {
              controller.deleteAddress(address.id);
            }
          },
          itemBuilder: (context) => [
            if (!address.isDefault)
              PopupMenuItem(value: 'default', child: Text(l10n.addresses_setDefault)),
            PopupMenuItem(value: 'delete', child: Text(l10n.common_delete)),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddAddressSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final labelController = TextEditingController(text: 'Home');
  final fullAddressController = TextEditingController();
  final cityController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.checkout_addAddress, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: labelController,
                decoration: InputDecoration(labelText: l10n.checkout_addressLabel, border: const OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? l10n.common_required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: fullAddressController,
                decoration: InputDecoration(labelText: l10n.checkout_fullAddress, border: const OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? l10n.common_required : null,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(labelText: l10n.checkout_city, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  await ref.read(addressControllerProvider.notifier).addAddress(
                        label: labelController.text.trim(),
                        fullAddress: fullAddressController.text.trim(),
                        city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
                      );
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(l10n.common_save),
              ),
            ],
          ),
        ),
      );
    },
  );
}
