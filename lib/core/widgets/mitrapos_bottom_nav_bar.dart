import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';

class MitraPOSBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MitraPOSBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_BottomNavItemData>[
      const _BottomNavItemData(icon: Icons.home_filled, label: 'Beranda'),
      const _BottomNavItemData(icon: Icons.inventory_2_outlined, label: 'Produk'),
      const _BottomNavItemData(icon: Icons.point_of_sale_outlined, label: 'Transaksi'),
      const _BottomNavItemData(icon: Icons.history_rounded, label: 'Riwayat'),
      const _BottomNavItemData(icon: Icons.move_to_inbox_outlined, label: 'Penerimaan'),
    ];

    return SafeArea(
      top: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceContainerLowest.withValues(alpha: 0.82),
                  AppColors.surface.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.indigoSurfaceTint.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 32,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                items.length,
                (index) => Expanded(
                  child: _BottomNavItem(
                    data: items[index],
                    selected: index == currentIndex,
                    onTap: () => onTap(index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  final IconData icon;
  final String label;

  const _BottomNavItemData({
    required this.icon,
    required this.label,
  });
}

class _BottomNavItem extends StatelessWidget {
  final _BottomNavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              size: 18,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                letterSpacing: 0.25,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
