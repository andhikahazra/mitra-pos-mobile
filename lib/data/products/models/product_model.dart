import 'package:mitrapos/domain/products/entities/product.dart';
import 'package:mitrapos/core/constants/app_constants.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.sku,
    required super.brand,
    required super.name,
    required super.price,
    required super.stock,
    required super.categoryName,
    super.panjangCm,
    super.lebarCm,
    super.tinggiCm,
    super.imageUrl,
    required super.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle category
    final category = json['kategori'];
    final categoryName = category != null ? category['nama'] : 'Umum';

    // Handle image
    final fotoPath = json['foto'] as String?;
    final imageUrl = (fotoPath != null && fotoPath.isNotEmpty)
        ? (fotoPath.startsWith('http')
            ? fotoPath
            : '${AppConstants.baseUrl.replaceAll('/api', '/storage')}/$fotoPath')
        : null;

    // Handle dimensions
    final dimensi = json['dimensi'];
    final panjang = json['panjang'] != null 
        ? double.parse(json['panjang'].toString())
        : (dimensi != null && dimensi['panjang'] != null 
            ? double.parse(dimensi['panjang'].toString()) 
            : 0.0);
    final lebar = json['lebar'] != null 
        ? double.parse(json['lebar'].toString())
        : (dimensi != null && dimensi['lebar'] != null 
            ? double.parse(dimensi['lebar'].toString()) 
            : 0.0);
    final tinggi = json['tinggi'] != null 
        ? double.parse(json['tinggi'].toString())
        : (dimensi != null && dimensi['tinggi'] != null 
            ? double.parse(dimensi['tinggi'].toString()) 
            : 0.0);

    return ProductModel(
      id: json['id'], // Actual Database ID
      sku: json['sku'] ?? '', // SKU Code
      brand: 'MitraPOS', 
      name: json['nama'],
      price: double.parse(json['harga'].toString()),
      stock: json['stok'],
      categoryName: categoryName,
      panjangCm: panjang,
      lebarCm: lebar,
      tinggiCm: tinggi,
      imageUrl: imageUrl,
      status: json['status'] == 1 || json['status'] == true,
    );
  }
}
