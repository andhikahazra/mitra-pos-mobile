import 'package:mitrapos/domain/products/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({required super.id, required super.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['nama'],
    );
  }
}
