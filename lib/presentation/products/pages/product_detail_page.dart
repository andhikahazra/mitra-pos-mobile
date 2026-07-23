import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/domain/products/entities/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock <= 10;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Detail Produk', style: AppTypePairing.headlineLg(color: AppColors.primary)),
                Text('Informasi lengkap katalog', style: AppTypePairing.bodySm()),
              ],
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroImage(product),
                const SizedBox(height: 20),
                _HeaderInfo(product, isLowStock),
                const SizedBox(height: 24),
                _PriceStockRow(product, isLowStock),
                const SizedBox(height: 24),
                _SpecsCard(product),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final Product product;
  const _HeroImage(this.product);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: AppColors.surfaceContainerLow,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _placeholderIcon(),
                      )
                    : _placeholderIcon(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Badge(
                label: product.categoryName,
                color: AppColors.primary,
                isLight: true,
              ),
              _Badge(
                label: product.status ? 'AKTIF' : 'NON-AKTIF',
                color: product.status ? AppColors.success : AppColors.error,
                isLight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholderIcon() {
    return const Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.textTertiary);
  }
}

class _HeaderInfo extends StatelessWidget {
  final Product product;
  final bool isLowStock;
  const _HeaderInfo(this.product, this.isLowStock);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTypePairing.headlineLg(color: AppColors.textPrimary).copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${product.sku.toUpperCase()}',
                      style: AppTypePairing.bodySm(color: AppColors.textSecondary, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (isLowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(
                        'Stok Rendah',
                        style: AppTypePairing.labelSmCaps(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (product.brand.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.label_outline, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  'Merek: ${product.brand}',
                  style: AppTypePairing.bodySm(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceStockRow extends StatelessWidget {
  final Product product;
  final bool isLowStock;
  const _PriceStockRow(this.product, this.isLowStock);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: _InfoBox(
              label: 'Harga Jual',
              value: 'Rp ${_formatRupiah(product.price)}',
              color: AppColors.primary,
              icon: Icons.attach_money_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _InfoBox(
              label: 'Stok Tersedia',
              value: '${product.stock} Unit',
              color: isLowStock ? AppColors.error : AppColors.success,
              icon: Icons.inventory_2_rounded,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(double value) {
    final digits = value.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}

class _SpecsCard extends StatelessWidget {
  final Product product;
  const _SpecsCard(this.product);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spesifikasi Produk', style: AppTypePairing.titleMd()),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _SpecRow(
                  icon: Icons.straighten_rounded,
                  label: 'Panjang',
                  value: '${product.panjangCm.toStringAsFixed(product.panjangCm == product.panjangCm.roundToDouble() ? 0 : 1)} cm',
                ),
                _Divider(),
                _SpecRow(
                  icon: Icons.straighten_rounded,
                  label: 'Lebar',
                  value: '${product.lebarCm.toStringAsFixed(product.lebarCm == product.lebarCm.roundToDouble() ? 0 : 1)} cm',
                ),
                _Divider(),
                _SpecRow(
                  icon: Icons.straighten_rounded,
                  label: 'Tinggi',
                  value: '${product.tinggiCm.toStringAsFixed(product.tinggiCm == product.tinggiCm.roundToDouble() ? 0 : 1)} cm',
                ),
                _Divider(),
                _SpecRow(
                  icon: Icons.scale_rounded,
                  label: 'Volume (Berat)',
                  value: '${(product.volumeCm3 / 6000).toStringAsFixed(2)} kg',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isLight;

  const _Badge({required this.label, required this.color, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLight ? color.withValues(alpha: 0.1) : color,
        borderRadius: BorderRadius.circular(8),
        border: isLight ? Border.all(color: color.withValues(alpha: 0.2)) : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypePairing.labelSmCaps(color: isLight ? color : Colors.white),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTypePairing.bodySm(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTypePairing.titleMd(color: color).copyWith(fontSize: 18)),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isBold;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(label, style: AppTypePairing.bodySm(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: isBold
                ? AppTypePairing.titleMd()
                : AppTypePairing.bodySm(color: AppColors.textPrimary, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: AppColors.borderLight);
  }
}