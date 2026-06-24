import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';

class StoreInfoCard extends StatefulWidget {
  final String storeName;
  final String username;
  final String category;
  final double rating;
  final int totalProducts;
  final int activeProducts;
  final int followers;

  const StoreInfoCard({
    super.key,
    required this.storeName,
    required this.username,
    required this.category,
    required this.rating,
    required this.totalProducts,
    required this.activeProducts,
    required this.followers,
  });

  @override
  State<StoreInfoCard> createState() => _StoreInfoCardState();
}

class _StoreInfoCardState extends State<StoreInfoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.indigoPrimary,
              AppColors.indigoPrimaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: _isHovered ? 0.18 : 0.12),
              blurRadius: _isHovered ? 24 : 16,
              offset: Offset(0, _isHovered ? 10 : 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    size: 19,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.storeName,
                        style: AppTypePairing.headlineLg(color: AppColors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.username} · ${widget.category}',
                        style: AppTypePairing.bodySm(
                          color: AppColors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildMetaItem('PRODUK', '${widget.totalProducts} item'),
                const SizedBox(width: 8),
                _buildMetaItem('AKTIF', '${widget.activeProducts} item'),
                const SizedBox(width: 8),
                _buildMetaItem('STOK', '${widget.followers} unit'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypePairing.labelSmCaps(
                color: AppColors.white.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypePairing.valueMd(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}