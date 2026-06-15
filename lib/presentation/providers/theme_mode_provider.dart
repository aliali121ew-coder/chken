import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import 'core_providers.dart';

/// Holds the active [ThemeMode] (light/dark/system), persisted across launches.
class AppThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.read(sharedPreferencesProvider).getString(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(StorageKeys.themeMode, mode.name);
  }
}

final themeModeProvider = NotifierProvider<AppThemeModeNotifier, ThemeMode>(AppThemeModeNotifier.new);
