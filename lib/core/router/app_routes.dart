/// Centralized route path constants for [GoRouter].
abstract final class AppRoutes {
  // Bootstrap
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';

  // Customer shell
  static const String home = '/home';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Customer detail routes
  static const String search = '/search';
  static const String product = '/product/:id';
  static const String store = '/store/:id';
  static const String checkout = '/checkout';
  static const String orderDetail = '/orders/:id';
  static const String addresses = '/addresses';
  static const String wishlist = '/wishlist';
  static const String notifications = '/notifications';
  static const String messages = '/messages';
  static const String wallet = '/wallet';
  static const String referral = '/referral';
  static const String chat = '/chat/:conversationId';

  // Vendor shell
  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorOrders = '/vendor/orders';
  static const String vendorProducts = '/vendor/products';
  static const String vendorChat = '/vendor/chat';
  static const String vendorSettings = '/vendor/settings';
  static const String vendorInventory = '/vendor/inventory';

  // Admin shell
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStores = '/admin/stores';
  static const String adminUsers = '/admin/users';
  static const String adminFinance = '/admin/finance';
  static const String adminCms = '/admin/cms';
  static const String adminAudit = '/admin/audit';

  // Delivery shell
  static const String deliveryActive = '/delivery/active';
  static const String deliveryHistory = '/delivery/history';
  static const String deliveryProfile = '/delivery/profile';

  static String productPath(String id) => '/product/$id';
  static String storePath(String id) => '/store/$id';
  static String orderDetailPath(String id) => '/orders/$id';
  static String chatPath(String conversationId) => '/chat/$conversationId';
}
