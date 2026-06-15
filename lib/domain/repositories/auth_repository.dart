import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/user_profile.dart';

/// Abstraction over Supabase Auth + the `profiles` table.
///
/// Implemented by [AuthRepositoryImpl] in the data layer. Supabase types
/// ([User], [AuthResponse]) are reused directly across layers, matching the
/// pragmatic pattern already used by `currentUserProvider`.
abstract class AuthRepository {
  /// Emits auth state changes (sign-in, sign-out, token refresh).
  Stream<AuthState> get authStateChanges;

  /// The currently authenticated user, or `null` if signed out.
  User? get currentUser;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<void> signOut();

  /// Sends a one-time password to [phone] via SMS.
  Future<void> sendPhoneOtp({required String phone});

  /// Verifies the [token] sent to [phone].
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  });

  Future<void> resetPasswordForEmail(String email);

  /// Returns the `profiles` row for [userId], creating a default
  /// `customer` profile from the auth user's metadata if none exists yet.
  Future<UserProfile?> getProfile(String userId);
}
