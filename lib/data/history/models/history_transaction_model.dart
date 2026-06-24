import 'package:mitrapos/domain/history/entities/history_transaction.dart';

class HistoryTransactionModel extends HistoryTransaction {
  const HistoryTransactionModel({
    required super.id,
    required super.kode,
    required super.tanggal,
    required super.cashierName,
    required super.metodePembayaran,
    required super.status,
    required super.totalHarga,
    required super.totalItems,
    required super.totalSku,
    super.biayaAdmin = 0,
    super.catatan = '',
    super.details,
  });

  factory HistoryTransactionModel.fromJson(Map<String, dynamic> json) {
    return HistoryTransactionModel(
      id: int.parse(json['id'].toString()),
      kode: json['kode'] ?? '',
      tanggal: DateTime.parse(json['tanggal']),
      cashierName: json['user']?['nama'] ?? '-',
      metodePembayaran: json['metode_pembayaran'] ?? '',
      status: json['status'] ?? 'Selesai',
      totalHarga: int.parse(json['total_harga'].toString().split('.')[0]),
      totalItems: json['total_items'] ?? 0,
      totalSku: json['total_sku'] ?? 0,
      biayaAdmin: double.tryParse(json['biaya_admin']?.toString() ?? '0')?.toInt() ?? 0,
      catatan: json['catatan'] ?? '',
      details: (json['detail_transaksi'] as List?)
              ?.map((d) => HistoryDetailModel.fromJson(d))
              .toList() ??
          const [],
    );
  }
}

class HistoryDetailModel extends HistoryDetail {
  const HistoryDetailModel({
    required super.id,
    required super.productName,
    required super.qty,
    required super.harga,
    required super.subtotal,
  });

  factory HistoryDetailModel.fromJson(Map<String, dynamic> json) {
    return HistoryDetailModel(
      id: int.parse(json['id'].toString()),
      productName: json['produk']?['nama'] ?? 'Produk Terhapus',
      qty: json['jumlah'] ?? 0,
      harga: int.parse(json['harga'].toString().split('.')[0]),
      subtotal: (json['jumlah'] ?? 0) *
          int.parse(json['harga'].toString().split('.')[0]),
    );
  }
}
