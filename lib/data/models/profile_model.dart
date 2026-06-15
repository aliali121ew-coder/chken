import '../../domain/entities/user_profile.dart';

/// Data-transfer object for the `profiles` table, decoupling the JSON
/// wire format (snake_case) from the [UserProfile] domain entity.
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.role,
    required this.fullName,
    required this.phone,
    required this.avatarUrl,
    required this.walletBalance,
    required this.loyaltyPoints,
    required this.loyaltyTier,
    required this.referralCode,
    required this.preferredLanguage,
    required this.preferredCurrency,
    required this.fcmToken,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      role: json['role'] as String? ?? 'customer',
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      loyaltyPoints: (json['loyalty_points'] as num?)?.toInt() ?? 0,
      loyaltyTier: json['loyalty_tier'] as String? ?? 'bronze',
      referralCode: json['referral_code'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'ar',
      preferredCurrency: json['preferred_currency'] as String? ?? 'USD',
      fcmToken: json['fcm_token'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String role;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final double walletBalance;
  final int loyaltyPoints;
  final String loyaltyTier;
  final String? referralCode;
  final String preferredLanguage;
  final String preferredCurrency;
  final String? fcmToken;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      role: UserRole.fromString(role),
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      walletBalance: walletBalance,
      loyaltyPoints: loyaltyPoints,
      loyaltyTier: loyaltyTier,
      referralCode: referralCode,
      preferredLanguage: preferredLanguage,
      preferredCurrency: preferredCurrency,
      fcmToken: fcmToken,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
