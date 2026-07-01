import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/domain/products/entities/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
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
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detail Produk',
                  style: AppTypePairing.headlineLg(color: AppColors.primary),
                ),
                Text(
                  'Informasi lengkap katalog',
                  style: AppTypePairing.bodySm(),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Product Preview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.indigoSurfaceTint.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 240,
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
            ),
            
            const SizedBox(height: 20),

            // 2. Core Information
            Text(
              product.name,
              style: AppTypePairing.headlineLg(color: AppColors.textPrimary).copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${product.sku.toUpperCase()}',
              style: AppTypePairing.bodySm(color: AppColors.textSecondary, weight: FontWeight.w600),
            ),

            const SizedBox(height: 24),

            // 3. Price & Stock Row
            Row(
              children: [
                Expanded(
                  child: _InfoBox(
                    label: 'Harga Jual',
                    value: 'Rp ${_formatRupiah(product.price)}',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoBox(
                    label: 'Stok Tersedia',
                    value: '${product.stock} Unit',
                    color: product.stock <= 10 ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. Specifications Card
            Text('Spesifikasi Produk', style: AppTypePairing.titleMd()),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.indigoSurfaceTint.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _SpecRow(label: 'Panjang', value: '${product.panjangCm} cm'),
                  _Divider(),
                  _SpecRow(label: 'Lebar', value: '${product.lebarCm} cm'),
                  _Divider(),
                  _SpecRow(label: 'Tinggi', value: '${product.tinggiCm} cm'),
                  _Divider(),
                  _SpecRow(
                    label: 'Volume (Berat)', 
                    value: '${(product.volumeCm3 / 6000).toStringAsFixed(2)} kg',
                    isBold: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return const Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.textTertiary);
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

  const _InfoBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.indigoSurfaceTint.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypePairing.bodySm(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypePairing.titleMd(color: color),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SpecRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypePairing.bodySm(color: AppColors.textSecondary)),
          Text(
            value,
            style: isBold ? AppTypePairing.titleMd() : AppTypePairing.bodySm(color: AppColors.textPrimary, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: AppColors.indigoSurfaceTint.withValues(alpha: 0.08)),
    );
  }
}
