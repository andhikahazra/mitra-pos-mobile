import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/widgets/mitrapos_bottom_nav_bar.dart';
import 'package:mitrapos/core/widgets/mitrapos_sidebar.dart';

/// Enum for current navigation item
enum AppNavItem { home, products, transactions, history, incoming }

/// Mapping of AppNavItem to index
int _indexOf(AppNavItem item) {
  switch (item) {
    case AppNavItem.home:
      return 0;
    case AppNavItem.products:
      return 1;
    case AppNavItem.transactions:
      return 2;
    case AppNavItem.history:
      return 3;
    case AppNavItem.incoming:
      return 4;
  }
}

/// AppNavItem from int
AppNavItem _itemFromIndex(int index) {
  switch (index) {
    case 0:
      return AppNavItem.home;
    case 1:
      return AppNavItem.products;
    case 2:
      return AppNavItem.transactions;
    case 3:
      return AppNavItem.history;
    case 4:
      return AppNavItem.incoming;
    default:
      return AppNavItem.home;
  }
}

/// Reusable tablet layout with sidebar navigation
class TabletLayout extends ConsumerStatefulWidget {
  final Widget child;
  final AppNavItem currentNav;
  final Function(AppNavItem) onNavTap;

  const TabletLayout({
    super.key,
    required this.child,
    required this.currentNav,
    required this.onNavTap,
  });

  @override
  ConsumerState<TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends ConsumerState<TabletLayout> {
  void _onNavTap(int index) {
    if (index == -1) {
      return;
    }
    widget.onNavTap(_itemFromIndex(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      body: SafeArea(
        child: Row(
          children: [
            MitraPOSSidebar(
              currentIndex: _indexOf(widget.currentNav),
              onTap: _onNavTap,
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}

/// Responsive wrapper: tablet uses sidebar, mobile uses bottom nav
class ResponsiveLayout extends ConsumerWidget {
  final Widget child;
  final AppNavItem currentNav;
  final Function(AppNavItem) onNavTap;
  final PreferredSizeWidget? mobileAppBar;
  final bool showBottomNavOnMobile;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.currentNav,
    required this.onNavTap,
    this.mobileAppBar,
    this.showBottomNavOnMobile = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 800;

        if (isTablet) {
          return TabletLayout(
            currentNav: currentNav,
            onNavTap: onNavTap,
            child: child,
          );
        }

        // Mobile: use Scaffold with optional AppBar and BottomNav
        return Scaffold(
          backgroundColor: context.surfaceContainerLowest,
          appBar: mobileAppBar,
          bottomNavigationBar: showBottomNavOnMobile
              ? MitraPOSBottomNavBar(
                  currentIndex: _indexOf(currentNav),
                  onTap: (index) => onNavTap(_itemFromIndex(index)),
                )
              : null,
          body: SafeArea(
            child: child,
          ),
        );
      }
    );
  }
}