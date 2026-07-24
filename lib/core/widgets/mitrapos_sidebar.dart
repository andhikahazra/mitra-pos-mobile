import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';

class _SidebarItemData {
  final IconData icon;
  final String label;

  const _SidebarItemData({required this.icon, required this.label});
}

class MitraPOSSidebar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MitraPOSSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const items = [
    _SidebarItemData(icon: Icons.home_rounded, label: 'Beranda'),
    _SidebarItemData(icon: Icons.inventory_2_rounded, label: 'Produk'),
    _SidebarItemData(icon: Icons.shopping_cart_rounded, label: 'Transaksi'),
    _SidebarItemData(icon: Icons.history_rounded, label: 'Riwayat'),
    _SidebarItemData(icon: Icons.inbox_rounded, label: 'Penerimaan'),
  ];

  @override
  State<MitraPOSSidebar> createState() => _MitraPOSSidebarState();
}

class _MitraPOSSidebarState extends State<MitraPOSSidebar> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(
          right: BorderSide(color: context.divider, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/branding/app_icon_blue_m.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MITRA POS',
                    style: AppTypePairing.labelSmCaps(
                      color: context.textPrimary,
                      weight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(MitraPOSSidebar.items.length, (index) {
              final item = MitraPOSSidebar.items[index];
              final selected = index == widget.currentIndex;
              final hovered = index == _hoveredIndex;
              return _SidebarItem(
                data: item,
                selected: selected,
                hovered: hovered,
                onTap: () => widget.onTap(index),
                onEnter: () => setState(() => _hoveredIndex = index),
                onExit: () => setState(() => _hoveredIndex = -1),
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Container(
                height: 1,
                color: context.divider,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _SidebarItem(
                data: const _SidebarItemData(icon: Icons.logout_rounded, label: 'Keluar'),
                selected: false,
                hovered: _hoveredIndex == 5,
                onTap: () => widget.onTap(-1),
                onEnter: () => setState(() => _hoveredIndex = 5),
                onExit: () => setState(() => _hoveredIndex = -1),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _SidebarItemData data;
  final bool selected;
  final bool hovered;
  final VoidCallback onTap;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  const _SidebarItem({
    required this.data,
    required this.selected,
    required this.hovered,
    required this.onTap,
    required this.onEnter,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.indigoPrimary
        : (hovered ? context.indigoPrimary : context.textSecondary);

    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: hovered && !selected
                ? context.indigoSurfaceTint.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                data.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                data.label,
                style: AppTypePairing.labelSmCaps(
                  color: color,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}