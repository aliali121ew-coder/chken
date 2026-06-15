import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_mode_provider.dart';

class DeliveryProfileScreen extends ConsumerWidget {
  const DeliveryProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(currentProfileProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(next.error))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(currentProfileProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProfileHeader(profile: profile),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(l10n.profile_language),
                    trailing: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
                    onTap: () => ref.read(localeProvider.notifier).toggle(),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: Text(l10n.profile_darkMode),
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) => ref.read(themeModeProvider.notifier).setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(l10n.auth_logout, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.profile_logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.common_cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.auth_logout)),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
          child: profile?.avatarUrl == null ? const Icon(Icons.person, size: 32) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.fullName?.isNotEmpty ?? false ? profile!.fullName! : l10n.profile_guest,
                style: theme.textTheme.titleLarge,
              ),
              if (profile?.phone != null) ...[
                const SizedBox(height: 4),
                Text(profile!.phone!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
