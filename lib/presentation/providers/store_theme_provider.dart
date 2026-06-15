import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/store_theme.dart';

/// Holds the currently active [StoreTheme] while the user browses a store.
///
/// `null` means the default app theme ([AppColors]) is used.
class StoreThemeNotifier extends Notifier<StoreTheme?> {
  @override
  StoreTheme? build() => null;

  void enter(StoreTheme theme) => state = theme;

  void clear() => state = null;
}

final storeThemeProvider = NotifierProvider<StoreThemeNotifier, StoreTheme?>(StoreThemeNotifier.new);
