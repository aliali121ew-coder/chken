import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/store.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../providers/vendor_providers.dart';

class VendorSettingsScreen extends ConsumerWidget {
  const VendorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeAsync = ref.watch(myStoreProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(next.error))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vendor_storeSettings)),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(myStoreProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (store) {
          if (store == null) {
            return Center(child: Text(l10n.vendor_noStore));
          }
          return _StoreSettingsForm(store: store);
        },
      ),
    );
  }
}

class _StoreSettingsForm extends ConsumerStatefulWidget {
  const _StoreSettingsForm({required this.store});

  final Store store;

  @override
  ConsumerState<_StoreSettingsForm> createState() => _StoreSettingsFormState();
}

class _StoreSettingsFormState extends ConsumerState<_StoreSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _deliveryFeeController;
  late final TextEditingController _minOrderController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.store.name);
    _nameEnController = TextEditingController(text: widget.store.nameEn ?? '');
    _descriptionController = TextEditingController(text: widget.store.description ?? '');
    _deliveryFeeController = TextEditingController(text: widget.store.deliveryFee.toString());
    _minOrderController = TextEditingController(text: widget.store.minOrderAmount.toString());
    _isActive = widget.store.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    _deliveryFeeController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(vendorControllerProvider).isLoading;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l10n.vendor_storeName, border: const OutlineInputBorder()),
            validator: (value) => value == null || value.trim().isEmpty ? l10n.common_required : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameEnController,
            decoration: InputDecoration(labelText: l10n.vendor_storeNameEn, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: l10n.vendor_storeDescription, border: const OutlineInputBorder()),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _deliveryFeeController,
            decoration: InputDecoration(labelText: l10n.vendor_deliveryFeeAmount, border: const OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return l10n.common_required;
              return double.tryParse(value) == null ? l10n.common_required : null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _minOrderController,
            decoration: InputDecoration(labelText: l10n.vendor_minOrderAmount, border: const OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return l10n.common_required;
              return double.tryParse(value) == null ? l10n.common_required : null;
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.vendor_storeActive),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    final ok = await ref.read(vendorControllerProvider.notifier).updateStoreSettings(
                          storeId: widget.store.id,
                          name: _nameController.text.trim(),
                          nameEn: _nameEnController.text.trim().isEmpty ? null : _nameEnController.text.trim(),
                          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                          deliveryFee: double.parse(_deliveryFeeController.text),
                          minOrderAmount: double.parse(_minOrderController.text),
                          isActive: _isActive,
                        );
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.common_save)));
                    }
                  },
            child: Text(l10n.common_save),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(l10n.auth_logout, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
