import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// Exposes the [AuthRepository] implementation to the widget tree.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Fetches (and lazily creates) the `profiles` row for the signed-in user.
///
/// Re-fetches whenever [currentUserProvider] changes (sign-in/sign-out).
final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(authRepositoryProvider).getProfile(user.id);
});

/// Drives the auth screens (login/register/OTP): exposes the in-flight
/// state of the current auth action and surfaces errors via [AsyncError].
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
    });
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
          );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
    });
  }

  Future<void> sendPhoneOtp({required String phone}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).sendPhoneOtp(phone: phone);
    });
  }

  Future<void> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).verifyPhoneOtp(
            phone: phone,
            token: token,
          );
    });
  }

  Future<void> resetPasswordForEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).resetPasswordForEmail(email);
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

/// Maps an [AuthException]/[Object] error from [authControllerProvider]
/// into a human-readable message.
String authErrorMessage(Object error) {
  if (error is AuthException) return error.message;
  return error.toString();
}
