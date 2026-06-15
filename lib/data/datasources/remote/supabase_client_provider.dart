import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/env.dart';

/// Initializes the Supabase SDK. Must be called once in `main()` before
/// [runApp], after [WidgetsFlutterBinding.ensureInitialized].
Future<void> initSupabase() async {
  Env.assertConfigured();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );
}

/// Exposes the initialized Supabase client to the Riverpod tree.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Emits the current auth state (sign-in, sign-out, token refresh, etc.).
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

/// The currently authenticated user, or `null` if signed out.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.value?.session?.user ?? Supabase.instance.client.auth.currentUser;
});
