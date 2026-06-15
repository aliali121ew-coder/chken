import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/repositories/order_repository.dart';
import '../../l10n/app_localizations.dart';
import '../providers/address_providers.dart';
import '../providers/cart_providers.dart';
import '../providers/coupon_providers.dart';
import '../providers/order_providers.dart';
import '../providers/store_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _notesController = TextEditingController();
  final _couponController = TextEditingController();
  String? _selectedAddressId;
  String _paymentMethod = 'cash';
  String _deliveryType = 'immediate';
  DateTime? _scheduledAt;
  Coupon? _appliedCoupon;
  bool _validatingCoupon = false;

  String _formatDateTime(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickScheduledTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  /// The discount the applied coupon yields against the matching store's
  /// subtotal in the current cart, or 0 if it doesn't apply.
  double _couponDiscount(List<CartItem> items) {
    final coupon = _appliedCoupon;
    if (coupon == null) return 0;
    final storeSubtotal = items
        .where((item) => item.storeId == coupon.storeId)
        .fold<double>(0, (sum, item) => sum + item.lineTotal);
    if (storeSubtotal <= 0) return 0;
    return coupon.discountFor(storeSubtotal);
  }

  Future<void> _applyCoupon(List<CartItem> items) async {
    final l10n = AppLocalizations.of(context);
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _validatingCoupon = true);
    final coupon = await ref.read(couponRepositoryProvider).findByCode(code);
    if (!mounted) return;
    setState(() => _validatingCoupon = false);

    String? error;
    if (coupon == null) {
      error = l10n.checkout_couponInvalid;
    } else {
      final storeSubtotal = items
          .where((item) => item.storeId == coupon.storeId)
          .fold<double>(0, (sum, item) => sum + item.lineTotal);
      if (storeSubtotal <= 0) {
        error = l10n.checkout_couponNotApplicable;
      } else if (storeSubtotal < coupon.minOrderAmount) {
        error = l10n.checkout_couponMinOrder;
      }
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _appliedCoupon = coupon);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.checkout_couponApplied)),
    );
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartAsync = ref.watch(cartItemsProvider);
    final addressesAsync = ref.watch(addressesProvider);
    final isPlacing = ref.watch(checkoutControllerProvider).isLoading;

    ref.listen(checkoutControllerProvider, (previous, next) {
      if (next is AsyncError) {
        final message = next.error is InsufficientWalletBalance
            ? l10n.checkout_insufficientWallet
            : next.error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    ref.listen(addressesProvider, (previous, next) {
      final addresses = next.value;
      if (addresses != null && addresses.isNotEmpty && _selectedAddressId == null) {
        setState(() {
          _selectedAddressId = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first).id;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkout_title)),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(l10n.common_error)),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.checkout_emptyCart));
          }

          final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
          final storeIds = items.map((item) => item.storeId).toSet();

          var deliveryFee = 0.0;
          for (final storeId in storeIds) {
            final store = ref.watch(storeByIdProvider(storeId)).value;
            if (store != null) deliveryFee += store.deliveryFee;
          }

          final discount = _couponDiscount(items);
          final total = subtotal + deliveryFee - discount;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.checkout_selectAddress, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              addressesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text(l10n.common_error),
                data: (addresses) => RadioGroup<String>(
                  groupValue: _selectedAddressId,
                  onChanged: (value) => setState(() => _selectedAddressId = value),
                  child: Column(
                    children: [
                      if (addresses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(l10n.checkout_noAddresses),
                        )
                      else
                        ...addresses.map(
                          (address) => RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: address.id,
                            title: Text(address.label),
                            subtitle: Text(
                              address.city != null ? '${address.fullAddress}, ${address.city}' : address.fullAddress,
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _showAddAddressSheet(context),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.checkout_addAddress),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),
              Text(l10n.checkout_deliveryType, style: Theme.of(context).textTheme.titleMedium),
              RadioGroup<String>(
                groupValue: _deliveryType,
                onChanged: (value) => setState(() {
                  _deliveryType = value!;
                  if (value != 'scheduled') _scheduledAt = null;
                }),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'immediate',
                      title: Text(l10n.checkout_immediate),
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'scheduled',
                      title: Text(l10n.checkout_scheduled),
                      subtitle: _scheduledAt != null ? Text('${l10n.checkout_scheduledAt}: ${_formatDateTime(_scheduledAt!)}') : null,
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'pickup',
                      title: Text(l10n.checkout_pickup),
                    ),
                  ],
                ),
              ),
              if (_deliveryType == 'scheduled')
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _pickScheduledTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(l10n.checkout_selectTime),
                  ),
                ),
              const Divider(height: 32),
              Text(l10n.checkout_paymentMethod, style: Theme.of(context).textTheme.titleMedium),
              RadioGroup<String>(
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value!),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'cash',
                      title: Text(l10n.checkout_cash),
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'stripe',
                      title: Text(l10n.checkout_card),
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'wallet',
                      title: Text(l10n.checkout_wallet),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.checkout_orderNotes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              if (_appliedCoupon == null)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          labelText: l10n.checkout_couponCode,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _validatingCoupon ? null : () => _applyCoupon(items),
                      child: _validatingCoupon
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.checkout_applyCoupon),
                    ),
                  ],
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.local_offer_outlined),
                  title: Text(_appliedCoupon!.code),
                  trailing: TextButton(onPressed: _removeCoupon, child: Text(l10n.checkout_remove)),
                ),
              const SizedBox(height: 16),
              _SummaryRow(label: l10n.cart_subtotal, value: subtotal),
              _SummaryRow(label: l10n.cart_deliveryFee, value: deliveryFee),
              if (discount > 0) _SummaryRow(label: l10n.cart_discount, value: -discount),
              const Divider(),
              _SummaryRow(label: l10n.cart_total, value: total, emphasize: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isPlacing || _selectedAddressId == null
                      ? null
                      : () => _placeOrder(context, discount),
                  child: isPlacing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.checkout_placeOrder),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, double discount) async {
    final l10n = AppLocalizations.of(context);
    final orderIds = await ref.read(checkoutControllerProvider.notifier).placeOrder(
          addressId: _selectedAddressId!,
          paymentMethod: _paymentMethod,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          couponId: _appliedCoupon?.id,
          couponStoreId: _appliedCoupon?.storeId,
          couponDiscount: discount,
          deliveryType: _deliveryType,
          scheduledAt: _deliveryType == 'scheduled' ? _scheduledAt : null,
        );

    if (!context.mounted || orderIds == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.checkout_orderPlaced)),
    );
    context.go(AppRoutes.orders);
  }

  Future<void> _showAddAddressSheet(BuildContext context) async {
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
                    final created = await ref.read(addressControllerProvider.notifier).addAddress(
                          label: labelController.text.trim(),
                          fullAddress: fullAddressController.text.trim(),
                          city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
                        );
                    if (context.mounted) Navigator.of(context).pop();
                    if (created != null) {
                      setState(() => _selectedAddressId = created.id);
                    }
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
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasize
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value.toStringAsFixed(2), style: style),
        ],
      ),
    );
  }
}
