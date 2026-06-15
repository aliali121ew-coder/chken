import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../providers/gift_card_providers.dart';
import '../providers/wallet_providers.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(currentProfileProvider).value;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.wallet_title),
          actions: [
            IconButton(
              tooltip: l10n.wallet_redeemGiftCard,
              icon: const Icon(Icons.redeem),
              onPressed: () => _showRedeemSheet(context, ref),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.wallet_walletTab),
              Tab(text: l10n.wallet_loyaltyTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _WalletTab(balance: profile?.walletBalance ?? 0),
            _LoyaltyTab(points: profile?.loyaltyPoints ?? 0, tier: profile?.loyaltyTier ?? 'bronze'),
          ],
        ),
      ),
    );
  }
}

class _WalletTab extends ConsumerWidget {
  const _WalletTab({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Column(
      children: [
        _BalanceHeader(label: l10n.wallet_balance, value: balance.toStringAsFixed(2)),
        Expanded(
          child: transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.common_error),
                  TextButton(
                    onPressed: () => ref.invalidate(walletTransactionsProvider),
                    child: Text(l10n.common_retry),
                  ),
                ],
              ),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Center(child: Text(l10n.wallet_noTransactions));
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(walletTransactionsProvider.future),
                child: ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final sign = tx.isCredit ? '+' : '-';
                    final color = tx.isCredit ? Colors.green : theme.colorScheme.error;
                    return ListTile(
                      leading: Icon(
                        tx.isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                        color: color,
                      ),
                      title: Text(tx.description ?? '—'),
                      subtitle: Text(_formatDate(tx.createdAt), style: theme.textTheme.bodySmall),
                      trailing: Text(
                        '$sign${tx.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LoyaltyTab extends ConsumerWidget {
  const _LoyaltyTab({required this.points, required this.tier});

  final int points;
  final String tier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(loyaltyTransactionsProvider);

    return Column(
      children: [
        _BalanceHeader(label: l10n.profile_loyaltyPoints, value: '$points ${l10n.wallet_points}', subtitle: tier),
        Expanded(
          child: transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.common_error),
                  TextButton(
                    onPressed: () => ref.invalidate(loyaltyTransactionsProvider),
                    child: Text(l10n.common_retry),
                  ),
                ],
              ),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Center(child: Text(l10n.wallet_noLoyalty));
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(loyaltyTransactionsProvider.future),
                child: ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final positive = tx.netPoints >= 0;
                    final color = positive ? Colors.green : theme.colorScheme.error;
                    return ListTile(
                      leading: Icon(Icons.card_giftcard_outlined, color: color),
                      title: Text(tx.description ?? '—'),
                      subtitle: Text(_formatDate(tx.createdAt), style: theme.textTheme.bodySmall),
                      trailing: Text(
                        '${positive ? '+' : ''}${tx.netPoints}',
                        style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.label, required this.value, this.subtitle});

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: theme.colorScheme.primaryContainer,
      child: Column(
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
          ],
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

Future<void> _showRedeemSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final isLoading = ref.watch(giftCardControllerProvider).isLoading;
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
                  Text(l10n.wallet_redeemGiftCard, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(labelText: l10n.wallet_giftCardCode, border: const OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty ? l10n.common_required : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!(formKey.currentState?.validate() ?? false)) return;
                            final amount = await ref.read(giftCardControllerProvider.notifier).redeem(codeController.text);
                            if (!context.mounted) return;
                            if (amount != null) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${l10n.wallet_giftCardRedeemed} (+${amount.toStringAsFixed(2)})')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.wallet_giftCardInvalid)),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.wallet_redeem),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
