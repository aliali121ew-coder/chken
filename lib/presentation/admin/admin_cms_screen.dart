import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/admin_repository.dart';
import '../../l10n/app_localizations.dart';
import '../providers/admin_providers.dart';

class AdminCmsScreen extends ConsumerWidget {
  const AdminCmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bannersAsync = ref.watch(adminBannersProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBannerSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: bannersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(adminBannersProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (banners) {
          if (banners.isEmpty) {
            return Center(child: Text(l10n.admin_noBanners));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(adminBannersProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: banners.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _BannerTile(banner: banners[index]),
            ),
          );
        },
      ),
    );
  }
}

class _BannerTile extends ConsumerWidget {
  const _BannerTile({required this.banner});

  final BannerItem banner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(adminControllerProvider).isLoading;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Colors.black12,
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          ListTile(
            title: Text(banner.titleAr ?? banner.titleEn ?? '—'),
            subtitle: Text(banner.isActive ? l10n.common_active : l10n.common_inactive),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: banner.isActive,
                  onChanged: isLoading
                      ? null
                      : (value) => ref.read(adminControllerProvider.notifier).setBannerActive(banner.id, value),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: isLoading
                      ? null
                      : () => ref.read(adminControllerProvider.notifier).deleteBanner(banner.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showAddBannerSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final imageUrlController = TextEditingController();
  final titleArController = TextEditingController();
  final titleEnController = TextEditingController();
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
              Text(l10n.admin_addBanner, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? l10n.common_required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: titleArController,
                decoration: InputDecoration(labelText: l10n.common_name, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: titleEnController,
                decoration: InputDecoration(labelText: l10n.common_nameEn, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final ok = await ref.read(adminControllerProvider.notifier).createBanner(
                        imageUrl: imageUrlController.text.trim(),
                        titleAr: titleArController.text.trim().isEmpty ? null : titleArController.text.trim(),
                        titleEn: titleEnController.text.trim().isEmpty ? null : titleEnController.text.trim(),
                      );
                  if (ok && context.mounted) Navigator.of(context).pop();
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
