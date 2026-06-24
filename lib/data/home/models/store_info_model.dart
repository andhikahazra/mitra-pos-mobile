import 'package:mitrapos/domain/home/entities/store_info.dart';

class StoreInfoModel extends StoreInfo {
  const StoreInfoModel({
    required super.name,
    required super.username,
    required super.category,
    required super.totalProducts,
    required super.activeProducts,
  });

  factory StoreInfoModel.fromJson(Map<String, dynamic> json) {
    return StoreInfoModel(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      category: json['category'] ?? '',
      totalProducts: json['totalProducts'] ?? 0,
      activeProducts: json['activeProducts'] ?? 0,
    );
  }
}
