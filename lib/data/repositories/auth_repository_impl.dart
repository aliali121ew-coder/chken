import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/profile_model.dart';

/// Supabase-backed implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': ?phone},
    );

    final user = response.user;
    if (user != null && response.session != null) {
      // Session is active immediately (email confirmation disabled) -
      // create the profile row now so it's available right away.
      await _client.from(SupabaseTables.profiles).upsert({
        'id': user.id,
        'full_name': fullName,
        'phone': ?phone,
      });
    }

    return response;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> sendPhoneOtp({required String phone}) {
    return _client.auth.signInWithOtp(phone: phone);
  }

  @override
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      type: OtpType.sms,
      phone: phone,
      token: token,
    );
  }

  @override
  Future<void> resetPasswordForEmail(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final row = await _client
        .from(SupabaseTables.profiles)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (row != null) {
      return ProfileModel.fromJson(row).toEntity();
    }

    // No profile row yet (e.g. first sign-in after email confirmation) -
    // create a default `customer` profile from the auth user's metadata.
    final user = _client.auth.currentUser;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};

    final created = await _client
        .from(SupabaseTables.profiles)
        .upsert({
          'id': userId,
          'full_name': metadata['full_name'],
          'phone': metadata['phone'],
        })
        .select()
        .single();

    return ProfileModel.fromJson(created).toEntity();
  }
}
