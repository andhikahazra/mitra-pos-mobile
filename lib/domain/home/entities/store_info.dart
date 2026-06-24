import 'package:equatable/equatable.dart';

class StoreInfo extends Equatable {
  final String name;
  final String username;
  final String category;
  final int totalProducts;
  final int activeProducts;

  const StoreInfo({
    required this.name,
    required this.username,
    required this.category,
    required this.totalProducts,
    required this.activeProducts,
  });

  @override
  List<Object?> get props => [name, username, category, totalProducts, activeProducts];
}
