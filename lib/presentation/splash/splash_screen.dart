import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Shown briefly on app launch while auth/session state is resolved.
/// [AppRouter]'s redirect logic sends the user to onboarding, auth or home.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront, color: Colors.white, size: 72),
            SizedBox(height: 16),
            Text(
              'MarketX',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
