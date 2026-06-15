/// The role assigned to a user, matching the `profiles.role` check
/// constraint in the Supabase schema (`customer`, `vendor`, `delivery`,
/// `admin`).
enum UserRole {
  customer,
  vendor,
  delivery,
  admin;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.customer,
    );
  }
}

/// Domain entity mirroring a row of the `profiles` table.
class UserProfile {
  const UserProfile({
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

  final String id;
  final UserRole role;
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
}
