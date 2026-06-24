import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id; // ID database asli (Primary Key)
  final String sku; // Kode SKU unik
  final String brand;
  final String name;
  final double price;
  final int stock;
  final String categoryName;
  final double panjangCm;
  final double lebarCm;
  final double tinggiCm;
  final String? imageUrl;
  final bool status;

  const Product({
    required this.id,
    required this.sku,
    required this.brand,
    required this.name,
    required this.price,
    required this.stock,
    required this.categoryName,
    this.panjangCm = 0,
    this.lebarCm = 0,
    this.tinggiCm = 0,
    this.imageUrl,
    required this.status,
  });

  double get volumeCm3 => panjangCm * lebarCm * tinggiCm;

  @override
  List<Object?> get props => [
        id,
        sku,
        brand,
        name,
        price,
        stock,
        categoryName,
        panjangCm,
        lebarCm,
        tinggiCm,
        imageUrl,
        status,
      ];
}
