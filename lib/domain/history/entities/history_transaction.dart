import 'package:equatable/equatable.dart';

class HistoryTransaction extends Equatable {
  final int id;
  final String kode;
  final DateTime tanggal;
  final String cashierName;
  final String metodePembayaran;
  final String status;
  final int totalHarga;
  final int totalItems;
  final int totalSku;
  final int biayaAdmin;
  final String catatan;
  final List<HistoryDetail> details;

  const HistoryTransaction({
    required this.id,
    required this.kode,
    required this.tanggal,
    required this.cashierName,
    required this.metodePembayaran,
    required this.status,
    required this.totalHarga,
    required this.totalItems,
    required this.totalSku,
    this.biayaAdmin = 0,
    this.catatan = '',
    this.details = const [],
  });

  @override
  List<Object?> get props => [
        id,
        kode,
        tanggal,
        cashierName,
        metodePembayaran,
        status,
        totalHarga,
        totalItems,
        totalSku,
        biayaAdmin,
        catatan,
        details,
      ];
}

class HistoryDetail extends Equatable {
  final int id;
  final String productName;
  final int qty;
  final int harga;
  final int subtotal;

  const HistoryDetail({
    required this.id,
    required this.productName,
    required this.qty,
    required this.harga,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [id, productName, qty, harga, subtotal];
}
