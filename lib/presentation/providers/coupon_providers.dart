import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/coupon_repository_impl.dart';
import '../../domain/repositories/coupon_repository.dart';

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return CouponRepositoryImpl(ref.watch(supabaseClientProvider));
});
