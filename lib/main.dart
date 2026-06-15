import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/remote/supabase_client_provider.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/core_providers.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/store_theme_provider.dart';
import 'presentation/providers/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await initSupabase();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MarketXApp(),
    ),
  );
}

class MarketXApp extends ConsumerWidget {
  const MarketXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final storeTheme = ref.watch(storeThemeProvider);

    return MaterialApp.router(
      title: 'MarketX',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: themeMode,
      theme: AppTheme.light(locale: locale, storeTheme: storeTheme),
      darkTheme: AppTheme.dark(locale: locale, storeTheme: storeTheme),
    );
  }
}
