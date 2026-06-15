import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import 'core_providers.dart';

/// Holds the active app locale (`ar` or `en`), persisted across launches.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.read(sharedPreferencesProvider).getString(StorageKeys.locale);
    return Locale(saved ?? 'ar');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(sharedPreferencesProvider).setString(StorageKeys.locale, locale.languageCode);
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
