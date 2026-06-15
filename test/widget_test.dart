// Basic smoke test: the app boots and shows the splash screen.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:marketx/main.dart';
import 'package:marketx/presentation/providers/core_providers.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      publishableKey: 'test-anon-key',
    );
  });

  testWidgets('App boots and shows the splash screen', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MarketXApp(),
      ),
    );

    // No authenticated session -> router redirects splash to onboarding.
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsOneWidget);
  });
}
