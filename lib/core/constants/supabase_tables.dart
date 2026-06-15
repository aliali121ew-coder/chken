/// Table names from the Supabase PostgreSQL schema (see supabase/migrations).
abstract final class SupabaseTables {
  static const String profiles = 'profiles';
  static const String stores = 'stores';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String addresses = 'addresses';
  static const String cartItems = 'cart_items';
  static const String orders = 'orders';
  static const String orderItems = 'order_items';
  static const String deliveryTracking = 'delivery_tracking';
  static const String coupons = 'coupons';
  static const String loyaltyTransactions = 'loyalty_transactions';
  static const String reviews = 'reviews';
  static const String chatMessages = 'chat_messages';
  static const String notifications = 'notifications';
  static const String wishlists = 'wishlists';
  static const String giftCards = 'gift_cards';
  static const String walletTransactions = 'wallet_transactions';
  static const String referrals = 'referrals';
  static const String priceAlerts = 'price_alerts';
  static const String auditLogs = 'audit_logs';
  static const String banners = 'banners';
  static const String inventoryLogs = 'inventory_logs';
}

/// Storage bucket names from Supabase Storage.
abstract final class SupabaseBuckets {
  static const String avatars = 'avatars';
  static const String storeAssets = 'store-assets';
  static const String productImages = 'product-images';
  static const String productVideos = 'product-videos';
  static const String arModels = 'ar-models';
  static const String reviewImages = 'review-images';
  static const String storeDocs = 'store-docs';
  static const String invoices = 'invoices';
}
