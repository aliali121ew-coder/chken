import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.watch(supabaseClientProvider));
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) {
  return ref.watch(adminRepositoryProvider).getDashboardStats();
});

final pendingStoresProvider = FutureProvider<List<Store>>((ref) {
  return ref.watch(adminRepositoryProvider).getPendingStores();
});

final allStoresProvider = FutureProvider<List<Store>>((ref) {
  return ref.watch(adminRepositoryProvider).getAllStores();
});

final adminUsersProvider = FutureProvider<List<UserProfile>>((ref) {
  return ref.watch(adminRepositoryProvider).getUsers();
});

final adminBannersProvider = FutureProvider<List<BannerItem>>((ref) {
  return ref.watch(adminRepositoryProvider).getBanners();
});

final adminAuditLogsProvider = FutureProvider<List<AuditLogEntry>>((ref) {
  return ref.watch(adminRepositoryProvider).getAuditLogs();
});

/// Drives admin mutations: store approvals, user/store status toggles and
/// CMS banner management.
class AdminController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> setStoreApproval(String storeId, bool isApproved) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).setStoreApproval(storeId, isApproved);
    });
    ref.invalidate(pendingStoresProvider);
    ref.invalidate(allStoresProvider);
    return !state.hasError;
  }

  Future<bool> setStoreActive(String storeId, bool isActive) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).setStoreActive(storeId, isActive);
    });
    ref.invalidate(allStoresProvider);
    ref.invalidate(pendingStoresProvider);
    return !state.hasError;
  }

  Future<bool> setUserActive(String userId, bool isActive) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).setUserActive(userId, isActive);
    });
    ref.invalidate(adminUsersProvider);
    return !state.hasError;
  }

  Future<bool> createBanner({required String imageUrl, String? titleAr, String? titleEn}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).createBanner(imageUrl: imageUrl, titleAr: titleAr, titleEn: titleEn);
    });
    ref.invalidate(adminBannersProvider);
    return !state.hasError;
  }

  Future<bool> setBannerActive(String bannerId, bool isActive) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).setBannerActive(bannerId, isActive);
    });
    ref.invalidate(adminBannersProvider);
    return !state.hasError;
  }

  Future<bool> deleteBanner(String bannerId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).deleteBanner(bannerId);
    });
    ref.invalidate(adminBannersProvider);
    return !state.hasError;
  }
}

final adminControllerProvider = AsyncNotifierProvider<AdminController, void>(AdminController.new);
