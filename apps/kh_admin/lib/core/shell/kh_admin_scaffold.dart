import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/auth/dev_auth.dart';
import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/router/admin_routes.dart';

/// Navigation item definition.
class AdminNavItem {
  const AdminNavItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.isLive = false,
  });

  final String id;
  final String title;
  final IconData icon;
  final String route;
  final bool isLive;
}

/// Navigation items matching ui-mock/js/nav.js admin ordering.
const List<AdminNavItem> kAdminNavItems = [
  AdminNavItem(
    id: 'ADM-S02',
    title: 'Dashboard',
    icon: Icons.dashboard_outlined,
    route: AdminRoutes.dashboard,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S03',
    title: 'Customers',
    icon: Icons.people_outline,
    route: AdminRoutes.customers,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S05',
    title: 'Vendors',
    icon: Icons.storefront_outlined,
    route: AdminRoutes.vendors,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S07',
    title: 'Verification Queue',
    icon: Icons.verified_user_outlined,
    route: AdminRoutes.verification,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S08',
    title: 'Requests',
    icon: Icons.assignment_outlined,
    route: AdminRoutes.requests,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S10',
    title: 'Offers',
    icon: Icons.local_offer_outlined,
    route: AdminRoutes.offers,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S12',
    title: 'Connections',
    icon: Icons.link_outlined,
    route: AdminRoutes.connections,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S14',
    title: 'Categories',
    icon: Icons.category_outlined,
    route: AdminRoutes.categories,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S15',
    title: 'Regions',
    icon: Icons.public_outlined,
    route: AdminRoutes.regions,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S16',
    title: 'Review Moderation',
    icon: Icons.rate_review_outlined,
    route: AdminRoutes.moderation,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S17',
    title: 'Reports & Analytics',
    icon: Icons.bar_chart_outlined,
    route: AdminRoutes.reports,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S18',
    title: 'Announcements',
    icon: Icons.campaign_outlined,
    route: AdminRoutes.announcements,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S19',
    title: 'Platform Settings',
    icon: Icons.tune_outlined,
    route: AdminRoutes.settings,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S21',
    title: 'Abuse Reports',
    icon: Icons.flag_outlined,
    route: AdminRoutes.abuse,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S22',
    title: 'Audit Log',
    icon: Icons.history_outlined,
    route: AdminRoutes.audit,
    isLive: true,
  ),
  AdminNavItem(
    id: 'ADM-S23',
    title: 'Admin Users',
    icon: Icons.manage_accounts_outlined,
    route: AdminRoutes.adminUsers,
    isLive: true,
  ),
];

/// Below this width the top bar sheds its decorative badges and the profile
/// name, keeping the drawer, identity and sign-out reachable on a phone.
const double kCompactTopBarWidth = 600.0;

/// Responsive breakpoint for desktop admin layout (Architecture-Frontend §4).
const double kDesktopBreakpoint = 1280.0;

/// SH-ADM-01: Karat Hive Admin Shell Scaffold.
/// Features a responsive sidebar (permanent on >= 1280px, drawer on < 1280px),
/// top bar with admin identity profile & logout, and routed child content.
class KhAdminScaffold extends ConsumerWidget {
  const KhAdminScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= kDesktopBreakpoint;
    final session = ref.watch(sessionControllerProvider);
    final displayName = session.admin?.displayName ?? 'Admin';
    final isDevAutoLogin = ref.watch(devAuthConfigProvider).autoLogin;

    final currentPath = GoRouterState.of(context).uri.path;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: context.kh.colors.backgroundPrimary,
        body: Row(
          children: [
            _AdminSidebar(
              currentPath: currentPath,
              onNavigate: (route) => context.go(route),
            ),
            Expanded(
              child: Column(
                children: [
                  _AdminTopBar(
                    displayName: displayName,
                    showDevBadge: isDevAutoLogin,
                    showHamburger: false,
                    onLogout: () =>
                        ref.read(sessionControllerProvider.notifier).logout(),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / Tablet (< 1280px)
    return Scaffold(
      backgroundColor: context.kh.colors.backgroundPrimary,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(context.kh.spacing.topBarHeight),
        child: _AdminTopBar(
          displayName: displayName,
          showDevBadge: isDevAutoLogin,
          showHamburger: true,
          onLogout: () =>
              ref.read(sessionControllerProvider.notifier).logout(),
        ),
      ),
      drawer: Drawer(
        backgroundColor: context.kh.colors.backgroundElevated,
        child: _AdminSidebar(
          currentPath: currentPath,
          onNavigate: (route) {
            Navigator.of(context).pop(); // Close drawer
            context.go(route);
          },
        ),
      ),
      body: child,
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.displayName,
    required this.onLogout,
    this.showHamburger = false,
    this.showDevBadge = false,
  });

  final String displayName;
  final VoidCallback onLogout;
  final bool showHamburger;

  /// True when `--dart-define=KH_DEV_AUTOLOGIN=true` bypassed the login screen.
  /// Surfaced so the flag can never ship unnoticed.
  final bool showDevBadge;

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;

    // A phone cannot hold brand + badges + profile name + sign out on one
    // line, so the decorative pieces drop out first. The bar spans the full
    // window in drawer mode, and in desktop mode the sidebar only narrows it
    // at widths that are never compact, so window width is the right measure.
    final isCompact = MediaQuery.sizeOf(context).width < kCompactTopBarWidth;

    return Container(
      height: spacing.topBarHeight,
      padding: EdgeInsets.symmetric(horizontal: spacing.lg),
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        border: Border(
          bottom: BorderSide(color: colors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (showHamburger) ...[
            IconButton(
              icon: Icon(Icons.menu, color: colors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open navigation',
            ),
            SizedBox(width: spacing.sm),
          ],
          // Title / Brand badge
          Flexible(
            child: Text(
              'KARAT HIVE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.title.copyWith(
                color: colors.goldPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 16,
              ),
            ),
          ),
          if (!isCompact) ...[
          SizedBox(width: spacing.xs),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.backgroundSurface,
              borderRadius: shapes.roundedXs,
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Text(
              'ADMIN',
              style: typography.caption.copyWith(
                color: colors.gold200,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ],
          if (showDevBadge) ...[
            SizedBox(width: spacing.xs),
            Container(
              key: const Key('dev-autologin-badge'),
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.15),
                borderRadius: shapes.roundedXs,
                border: Border.all(color: colors.error.withValues(alpha: 0.6)),
              ),
              child: Text(
                isCompact ? 'DEV' : 'DEV AUTO-LOGIN',
                style: typography.caption.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
          const Spacer(),
          // Admin Profile chip
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.backgroundSurface,
              borderRadius: shapes.roundedSm,
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: colors.goldPrimary.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person_outline,
                    size: 14,
                    color: colors.goldPrimary,
                  ),
                ),
                if (!isCompact) ...[
                  SizedBox(width: spacing.sm),
                  Text(
                    displayName,
                    style: typography.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: isCompact ? spacing.xs : spacing.md),
          // Logout button
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              size: 20,
              color: colors.textSecondary,
            ),
            tooltip: 'Log out',
            hoverColor: colors.error.withValues(alpha: 0.15),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: colors.backgroundElevated,
                  title: Text('Confirm Sign Out', style: typography.title),
                  content: Text(
                    'Are you sure you want to end your administrative session?',
                    style: typography.body,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text('Cancel', style: typography.bodySmall),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: colors.cream100,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('Sign Out', style: typography.bodySmall),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                onLogout();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.currentPath,
    required this.onNavigate,
  });

  final String currentPath;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final spacing = context.kh.spacing;
    final typography = context.kh.typography;

    return Container(
      width: spacing.sidebarWidth,
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        border: Border(
          right: BorderSide(color: colors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Header / Logo
          Container(
            height: spacing.topBarHeight,
            padding: EdgeInsets.symmetric(horizontal: spacing.lg),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.borderSubtle, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.diamond_outlined,
                  color: colors.goldPrimary,
                  size: 22,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    'Karat Hive Portal',
                    style: typography.title.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable navigation list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: spacing.sm,
                horizontal: spacing.sm,
              ),
              itemCount: kAdminNavItems.length,
              separatorBuilder: (_, __) => SizedBox(height: spacing.xxs),
              itemBuilder: (context, index) {
                final item = kAdminNavItems[index];
                final isSelected = item.route == '/'
                    ? currentPath == '/'
                    : currentPath.startsWith(item.route);

                return _NavItemTile(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onNavigate(item.route),
                );
              },
            ),
          ),
          // Sidebar Footer / Version Info
          Container(
            padding: EdgeInsets.all(spacing.md),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colors.borderSubtle, width: 1),
              ),
            ),
            child: Text(
              'v1.0.0 • UAE Admin',
              style: typography.caption.copyWith(color: colors.mutedGold),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AdminNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final spacing = context.kh.spacing;
    final typography = context.kh.typography;
    final shapes = context.kh.shapes;

    final backgroundColor = isSelected
        ? colors.backgroundSurface
        : Colors.transparent;

    final iconColor = isSelected
        ? colors.goldPrimary
        : (item.isLive ? colors.cream200 : colors.textMuted);

    final textColor = isSelected
        ? colors.goldPrimary
        : (item.isLive ? colors.cream100 : colors.textMuted);

    return InkWell(
      onTap: onTap,
      borderRadius: shapes.roundedSm,
      hoverColor: colors.backgroundSurface.withValues(alpha: 0.5),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: shapes.roundedSm,
          border: isSelected
              ? Border(
                  left: BorderSide(color: colors.goldPrimary, width: 3),
                )
              : null,
        ),
        padding: EdgeInsets.symmetric(horizontal: spacing.md),
        child: Row(
          children: [
            Icon(item.icon, size: 18, color: iconColor),
            SizedBox(width: spacing.md),
            Expanded(
              child: Text(
                item.title,
                style: typography.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!item.isLive)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xs,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: colors.backgroundPrimary.withValues(alpha: 0.6),
                  borderRadius: shapes.roundedXs,
                ),
                child: Text(
                  'Soon',
                  style: typography.caption.copyWith(
                    color: colors.mutedGold,
                    fontSize: 9,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
