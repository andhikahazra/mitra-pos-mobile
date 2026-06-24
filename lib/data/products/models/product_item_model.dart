import 'package:mitrapos/domain/products/entities/product_item.dart';

class ListingItemModel extends ListingItem {
  const ListingItemModel({
    required super.id,
    required super.brand,
    required super.title,
    required super.price,
    required super.subtitle,
    required super.condition,
    required super.stock,
    super.panjangCm,
    super.lebarCm,
    super.tinggiCm,
    required super.imageUrl,
    required super.status,
  });
}

