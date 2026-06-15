import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// Navigation drawer shell for the admin role:
/// Dashboard | Stores | Users | Finance | CMS | Audit
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final items = [
      (icon: Icons.dashboard_outlined, label: l10n.navDashboard),
      (icon: Icons.storefront_outlined, label: l10n.navStores),
      (icon: Icons.people_outline, label: l10n.navUsers),
      (icon: Icons.account_balance_wallet_outlined, label: l10n.navFinance),
      (icon: Icons.campaign_outlined, label: l10n.navCms),
      (icon: Icons.fact_check_outlined, label: l10n.navAudit),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(items[navigationShell.currentIndex].label)),
      drawer: NavigationDrawer(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
          Navigator.of(context).pop();
        },
        children: [
          for (final item in items)
            NavigationDrawerDestination(icon: Icon(item.icon), label: Text(item.label)),
        ],
      ),
      body: navigationShell,
    );
  }
}
