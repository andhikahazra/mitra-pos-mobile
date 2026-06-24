import 'package:mitrapos/domain/transactions/entities/transaction_product.dart';

class TransactionProductModel extends TransactionProduct {
  const TransactionProductModel({
    required super.id,
    required super.sku,
    required super.nama,
    required super.kategori,
    required super.harga,
    required super.stok,
    super.imageUrl,
  });

  factory TransactionProductModel.fromJson(Map<String, dynamic> json) {
    return TransactionProductModel(
      id: int.parse(json['id'].toString()), // Map to int
      sku: json['sku'] ?? '', // Map to sku
      nama: json['nama'] as String,
      kategori: json['kategori'] != null && json['kategori'] is Map 
          ? json['kategori']['nama'] ?? 'Umum'
          : (json['kategori_nama'] ?? 'Umum'),
      harga: int.parse(json['harga']?.toString().split('.')[0] ?? '0'), 
      stok: int.parse(json['stok']?.toString().split('.')[0] ?? '0'),
      imageUrl: (json['foto'] != null && (json['foto'] as List).isNotEmpty) 
          ? json['foto'][0]['path'] 
          : null,
    );
  }
}
