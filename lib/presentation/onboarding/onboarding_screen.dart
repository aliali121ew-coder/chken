import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/router/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../providers/core_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(sharedPreferencesProvider).setBool(StorageKeys.hasSeenOnboarding, true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [l10n.onboarding_title1, l10n.onboarding_title2, l10n.onboarding_title3];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _finish, child: Text(l10n.common_skip)),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: titles.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      titles[index],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ),
            ),
            SmoothPageIndicator(controller: _controller, count: titles.length),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_page == titles.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    }
                  },
                  child: Text(_page == titles.length - 1 ? l10n.onboarding_getStarted : l10n.common_next),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
