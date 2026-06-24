import 'package:equatable/equatable.dart';

class TransactionProduct extends Equatable {
  final int id; // Ubah ke int
  final String sku; // Tambahkan sku jika perlu, tapi setidaknya id harus konsisten
  final String nama;
  final String kategori;
  final int harga;
  final int stok;
  final String? imageUrl;

  const TransactionProduct({
    required this.id,
    this.sku = '',
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, sku, nama, kategori, harga, stok, imageUrl];
}
