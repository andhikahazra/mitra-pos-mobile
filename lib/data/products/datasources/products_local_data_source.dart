import 'package:mitrapos/data/products/models/product_item_model.dart';

abstract class ProductsLocalDataSource {
  Future<List<ListingItemModel>> getListings();
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  @override
  Future<List<ListingItemModel>> getListings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      ListingItemModel(
        id: '1',
        brand: 'CHANEL',
        title: 'The Classic Chanel Flap in Black Lambskin',
        price: 7125,
        subtitle: 'Like New',
        condition: 'Very Good',
        stock: 4,
        panjangCm: 40,
        lebarCm: 30,
        tinggiCm: 25,
        imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=300',
        status: 'Active',
      ),
      ListingItemModel(
        id: '2',
        brand: 'CELINE',
        title: 'Celine Classic Box in Polished Calfskin',
        price: 750,
        subtitle: 'Calfskin',
        condition: 'Very Good',
        stock: 60,
        panjangCm: 30,
        lebarCm: 20,
        tinggiCm: 15,
        imageUrl: 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=300',
        status: 'Inactive',
      ),
      ListingItemModel(
        id: '3',
        brand: 'SAINT LAURENT',
        title: 'Sac de Jour in Structured Leather',
        price: 2900,
        subtitle: 'Very Good',
        condition: 'Very Good',
        stock: 2,
        panjangCm: 50,
        lebarCm: 35,
        tinggiCm: 28,
        imageUrl: 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=300',
        status: 'Active',
      ),
      ListingItemModel(
        id: '4',
        brand: 'DIOR',
        title: 'Lady Dior Medium in Matte Cannage Leather',
        price: 4176,
        subtitle: 'Very Good',
        condition: 'Very Good',
        stock: 1,
        panjangCm: 45,
        lebarCm: 32,
        tinggiCm: 30,
        imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=300',
        status: 'Draft',
      ),
    ];
  }
}

