import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';

class IncomingGoodsDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const IncomingGoodsDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String kode = data['kode'] ?? '-';
    final String status = data['status'] ?? 'Menunggu';
    final String supplierName = data['supplier']?['nama'] ?? 'Unknown';
    final String supplierPhone = data['supplier']?['no_telp'] ?? '-';
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

    // Calculate total
    double total = 0;
    for (var item in items) {
      final double price = double.tryParse(item['harga'].toString()) ?? 0;
      final int qty = int.tryParse(item['jumlah'].toString()) ?? 0;
      total += price * qty;
    }

    Color statusColor = AppColors.warning;
    Color statusBgColor = AppColors.warningLight;
    if (status == 'Diterima' || status == 'Disetujui' || status == 'Selesai') {
      statusColor = AppColors.success;
      statusBgColor = AppColors.successLight;
    } else if (status == 'Ditolak') {
      statusColor = AppColors.error;
      statusBgColor = AppColors.errorLight;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Detail Penerimaan'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(kode, style: AppTypePairing.headlineLg(color: AppColors.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: AppTypePairing.labelSmCaps(color: statusColor),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _InfoRow(label: 'Supplier', value: supplierName),
                _InfoRow(label: 'Kontak', value: supplierPhone),
                _InfoRow(label: 'Tgl Pesan', value: formattedOrderDate),
                _InfoRow(label: 'Tgl Terima', value: formattedDate),
                _InfoRow(label: 'Input Oleh', value: userInput),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          Text('Daftar Produk', style: AppTypePairing.titleMd()),
          const SizedBox(height: 10),
          
          // Items List
          ...items.map((item) {
            final product = item['produk'] ?? {};
            final String productName = product['nama'] ?? 'Product Deleted';
            final String sku = product['sku'] ?? '-';
            final int qty = int.tryParse(item['jumlah'].toString()) ?? 0;
            final double price = double.tryParse(item['harga'].toString()) ?? 0;
            final double subtotal = qty * price;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productName, style: AppTypePairing.valueMd(color: AppColors.textPrimary)),
                        Text('SKU: $sku', style: AppTypePairing.labelSmCaps(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '$qty x ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price)}',
                          style: AppTypePairing.bodySm(),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(subtotal),
                    style: AppTypePairing.valueMd(color: AppColors.primary),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          
          // Note Section
          if (catatan != '-' && catatan.isNotEmpty) ...[
            Text('Catatan', style: AppTypePairing.titleMd()),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(catatan, style: AppTypePairing.bodySm()),
            ),
            const SizedBox(height: 20),
          ],

          // Summary Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL PEMBAYARAN', style: AppTypePairing.valueMd(color: AppColors.primary)),
                Text(
                  NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total),
                  style: AppTypePairing.titleMd(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypePairing.bodySm(color: Colors.grey)),
          Text(value, style: AppTypePairing.bodySm(weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
