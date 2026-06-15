import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../../presentation/addresses/addresses_screen.dart';
import '../../presentation/admin/admin_audit_screen.dart';
import '../../presentation/admin/admin_cms_screen.dart';
import '../../presentation/admin/admin_dashboard_screen.dart';
import '../../presentation/admin/admin_finance_screen.dart';
import '../../presentation/admin/admin_shell.dart';
import '../../presentation/admin/admin_stores_screen.dart';
import '../../presentation/admin/admin_users_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/otp_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/delivery/delivery_active_screen.dart';
import '../../presentation/delivery/delivery_history_screen.dart';
import '../../presentation/delivery/delivery_profile_screen.dart';
import '../../presentation/delivery/delivery_shell.dart';
import '../../presentation/home/customer_shell.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/cart/cart_screen.dart';
import '../../presentation/chat/chat_screen.dart';
import '../../presentation/chat/conversations_screen.dart';
import '../../presentation/categories/categories_screen.dart';
import '../../presentation/checkout/checkout_screen.dart';
import '../../presentation/notifications/notifications_screen.dart';
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/orders/order_detail_screen.dart';
import '../../presentation/orders/orders_screen.dart';
import '../../presentation/product/product_detail_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/referral/referral_screen.dart';
import '../../presentation/providers/auth_providers.dart';
import '../../presentation/search/search_screen.dart';
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/store/store_screen.dart';
import '../../presentation/wallet/wallet_screen.dart';
import '../../presentation/wishlist/wishlist_screen.dart';
import '../../presentation/vendor/vendor_dashboard_screen.dart';
import '../../presentation/vendor/vendor_inventory_screen.dart';
import '../../presentation/vendor/vendor_orders_screen.dart';
import '../../presentation/vendor/vendor_products_screen.dart';
import '../../presentation/vendor/vendor_settings_screen.dart';
import '../../presentation/vendor/vendor_shell.dart';
import 'app_routes.dart';

/// ⚠️ TEMPORARY — DEV PREVIEW ONLY. Set back to `false` before shipping.
///
/// When `true`, the router stops forcing unauthenticated users to the login
/// screen, so the app's content (home, categories, cart, profile…) can be
/// browsed without a working Supabase backend. Data-driven screens will still
/// show empty/error states because there is no real server to fetch from.
const bool kDevBypassAuth = true;

/// Maps a user's role to the home route of their dedicated shell.
String _homeRouteForRole(UserRole role) {
  switch (role) {
    case UserRole.vendor:
      return AppRoutes.vendorDashboard;
    case UserRole.admin:
      return AppRoutes.adminDashboard;
    case UserRole.delivery:
      return AppRoutes.deliveryActive;
    case UserRole.customer:
      return AppRoutes.home;
  }
}

/// Listens to Supabase auth changes and notifies [GoRouter] to re-evaluate
/// its `redirect` callback (e.g. after sign-in/sign-out).
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authStateChangesProvider, (_, _) => notifyListeners());
    ref.listen(currentProfileProvider, (_, _) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _GoRouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated = ref.read(currentUserProvider) != null;
      final path = state.matchedLocation;

      // DEV PREVIEW: skip all auth gating so content is browsable offline.
      if (kDevBypassAuth) {
        if (path == AppRoutes.splash) return AppRoutes.home;
        return null;
      }

      final isAuthRoute = path == AppRoutes.login || path == AppRoutes.register || path == AppRoutes.otp;
      final isBootstrapRoute = path == AppRoutes.splash || path == AppRoutes.onboarding;

      if (path == AppRoutes.splash) {
        if (!isAuthenticated) return AppRoutes.onboarding;
        final role = ref.read(currentProfileProvider).value?.role;
        return role == null ? AppRoutes.home : _homeRouteForRole(role);
      }

      if (!isAuthenticated && !isAuthRoute && !isBootstrapRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isAuthRoute) {
        final role = ref.read(currentProfileProvider).value?.role;
        return role == null ? AppRoutes.home : _homeRouteForRole(role);
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => OtpScreen(phone: state.extra as String? ?? ''),
      ),

      // ── Customer shell ──────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => CustomerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.categories, builder: (context, state) => const CategoriesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.cart, builder: (context, state) => const CartScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.orders, builder: (context, state) => const OrdersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      // ── Customer detail routes (pushed above the shell) ────────────
      GoRoute(path: AppRoutes.search, builder: (context, state) => const SearchScreen()),
      GoRoute(
        path: AppRoutes.product,
        builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.store,
        builder: (context, state) => StoreScreen(storeId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.checkout, builder: (context, state) => const CheckoutScreen()),
      GoRoute(
        path: AppRoutes.orderDetail,
        builder: (context, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.wishlist, builder: (context, state) => const WishlistScreen()),
      GoRoute(path: AppRoutes.addresses, builder: (context, state) => const AddressesScreen()),
      GoRoute(path: AppRoutes.wallet, builder: (context, state) => const WalletScreen()),
      GoRoute(path: AppRoutes.vendorInventory, builder: (context, state) => const VendorInventoryScreen()),
      GoRoute(path: AppRoutes.referral, builder: (context, state) => const ReferralScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.messages, builder: (context, state) => const ConversationsScreen()),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => ChatScreen(
          conversationId: state.pathParameters['conversationId']!,
          args: state.extra as ChatArgs,
        ),
      ),

      // ── Vendor shell ─────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => VendorShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.vendorDashboard, builder: (context, state) => const VendorDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.vendorOrders, builder: (context, state) => const VendorOrdersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.vendorProducts, builder: (context, state) => const VendorProductsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.vendorChat, builder: (context, state) => const ConversationsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.vendorSettings, builder: (context, state) => const VendorSettingsScreen()),
          ]),
        ],
      ),

      // ── Admin shell ──────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.adminDashboard, builder: (context, state) => const AdminDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.adminStores, builder: (context, state) => const AdminStoresScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.adminUsers, builder: (context, state) => const AdminUsersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.adminFinance, builder: (context, state) => const AdminFinanceScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.adminCms, builder: (context, state) => const AdminCmsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.adminAudit, builder: (context, state) => const AdminAuditScreen()),
          ]),
        ],
      ),

      // ── Delivery shell ───────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => DeliveryShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.deliveryActive, builder: (context, state) => const DeliveryActiveScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.deliveryHistory, builder: (context, state) => const DeliveryHistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.deliveryProfile, builder: (context, state) => const DeliveryProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});
