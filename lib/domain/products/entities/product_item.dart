import 'package:equatable/equatable.dart';

class ListingItem extends Equatable {
  final String id;
  final String brand;
  final String title;
  final int price;
  final String subtitle;
  final String condition;
  final int stock;
  final double panjangCm;
  final double lebarCm;
  final double tinggiCm;
  final String imageUrl;
  final String status;

  const ListingItem({
    required this.id,
    required this.brand,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.condition,
    required this.stock,
    this.panjangCm = 0,
    this.lebarCm = 0,
    this.tinggiCm = 0,
    required this.imageUrl,
    required this.status,
  });

  double get volumeCm3 => panjangCm * lebarCm * tinggiCm;

  @override
  List<Object?> get props => [
        id,
        brand,
        title,
        price,
        subtitle,
        condition,
        stock,
        panjangCm,
        lebarCm,
        tinggiCm,
        imageUrl,
        status,
      ];
}
