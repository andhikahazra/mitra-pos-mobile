import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/constants/app_constants.dart';

class IncomingGoodsDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const IncomingGoodsDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String kode = data['kode'] ?? '-';
    final String status = data['status'] ?? 'Menunggu';
    final String supplierName = data['supplier']?['nama'] ?? 'Unknown';
    final String supplierPhone = data['supplier']?['no_telp'] ?? '-';
    final String? fotoStrukPath = data['foto_struk'] as String?;
    final String? fotoStrukUrl = (fotoStrukPath != null && fotoStrukPath.isNotEmpty)
        ? (fotoStrukPath.startsWith('http')
            ? fotoStrukPath
            : '${AppConstants.baseUrl.replaceAll('/api', '/storage')}/$fotoStrukPath')
        : null;
    final String dateStr = data['tanggal_terima'] ?? '';
    final String orderDateStr = data['tanggal_pesan'] ?? '';
    final String formattedDate = dateStr.isNotEmpty 
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr).toLocal())
        : '-';
    final String formattedOrderDate = orderDateStr.isNotEmpty 
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(orderDateStr).toLocal())
        : '-';
    final String userInput = data['user']?['nama'] ?? '-';
    final List items = data['detail'] ?? [];
    final String catatan = data['catatan'] ?? '-';

    double total = 0;
    for (var item in items) {
      final double price = double.tryParse(item['harga'].toString()) ?? 0;
      final int qty = int.tryParse(item['jumlah'].toString()) ?? 0;
      total += price * qty;
    }

    Color statusColor = AppColors.warning;
    Color statusBgColor = AppColors.warningLight;
    IconData statusIcon = Icons.schedule_rounded;
    if (status == 'Diterima' || status == 'Disetujui' || status == 'Selesai') {
      statusColor = AppColors.success;
      statusBgColor = AppColors.successLight;
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'Ditolak') {
      statusColor = AppColors.error;
      statusBgColor = AppColors.errorLight;
      statusIcon = Icons.cancel_rounded;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Penerimaan'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _DashboardCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kode,
                        style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi',
                  style: AppTypePairing.titleMd(weight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _InfoRow(label: 'Supplier', value: supplierName),
                const SizedBox(height: 12),
                _InfoRow(label: 'Kontak', value: supplierPhone),
                const SizedBox(height: 12),
                _InfoRow(label: 'Tgl Pesan', value: formattedOrderDate),
                const SizedBox(height: 12),
                _InfoRow(label: 'Tgl Terima', value: formattedDate),
                const SizedBox(height: 12),
                _InfoRow(label: 'Input Oleh', value: userInput),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Produk',
                      style: AppTypePairing.titleMd(weight: FontWeight.w700),
                    ),
                    Text(
                      '${items.length} item',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Tidak ada produk',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(flex: 3, child: Text('Produk', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                      Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text('Harga', textAlign: TextAlign.right, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text('Subtotal', textAlign: TextAlign.right, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 8),
                  ...items.map((item) {
                    final product = item['produk'] ?? {};
                    final String productName = product['nama'] ?? 'Product Deleted';
                    final String sku = product['sku'] ?? '-';
                    final int qty = int.tryParse(item['jumlah'].toString()) ?? 0;
                    final double price = double.tryParse(item['harga'].toString()) ?? 0;
                    final double subtotal = qty * price;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'SKU: $sku',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              qty.toString(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(price),
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(subtotal),
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (catatan != '-' && catatan.isNotEmpty) ...[
            _DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catatan', style: AppTypePairing.titleMd(weight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text(catatan, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL PEMBAYARAN',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total),
                  style: AppTextStyles.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (fotoStrukUrl != null) ...[
            const SizedBox(height: 20),
            Text('Foto Struk / Invoice', style: AppTypePairing.titleMd(weight: FontWeight.w700)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                fotoStrukUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;

  const _DashboardCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Text(':', style: AppTextStyles.bodySmall),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
