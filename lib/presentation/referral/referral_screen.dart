import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/referral.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../providers/referral_providers.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final code = ref.watch(currentProfileProvider).value?.referralCode ?? '';
    final referralsAsync = ref.watch(myReferralsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.referral_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.referral_intro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(l10n.referral_yourCode, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  SelectableText(
                    code,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: code.isEmpty
                              ? null
                              : () async {
                                  await Clipboard.setData(ClipboardData(text: code));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.referral_copied)),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.copy, size: 18),
                          label: Text(l10n.referral_copy),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: code.isEmpty
                              ? null
                              : () => SharePlus.instance.share(
                                    ShareParams(text: '${l10n.referral_intro}\n\n$code'),
                                  ),
                          icon: const Icon(Icons.share, size: 18),
                          label: Text(l10n.referral_share),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.referral_invitedFriends, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          referralsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (error, stackTrace) => Text(l10n.common_error),
            data: (referrals) {
              if (referrals.isEmpty) {
                return Text(l10n.referral_none, style: theme.textTheme.bodyMedium);
              }
              return Column(children: [for (final r in referrals) _ReferralTile(referral: r)]);
            },
          ),
        ],
      ),
    );
  }
}

class _ReferralTile extends StatelessWidget {
  const _ReferralTile({required this.referral});

  final Referral referral;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(referral.referredName?.isNotEmpty ?? false ? referral.referredName! : l10n.profile_guest),
        trailing: Text(
          referral.rewardGiven ? l10n.referral_rewardGiven : l10n.referral_rewardPending,
          style: theme.textTheme.labelSmall?.copyWith(
            color: referral.rewardGiven ? Colors.green : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
