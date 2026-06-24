import 'package:mitrapos/data/transactions/models/transaction_product_model.dart';

abstract class TransactionsLocalDataSource {
  Future<List<TransactionProductModel>> getProdukTransaksi();
}

class TransactionsLocalDataSourceImpl implements TransactionsLocalDataSource {
  @override
  Future<List<TransactionProductModel>> getProdukTransaksi() async {
    return const [
      TransactionProductModel(
        id: 1,
        sku: 'TKMP-P001',
        nama: 'Kopi Susu Aren',
        kategori: 'Minuman',
        harga: 22000,
        stok: 50,
        imageUrl: 'https://images.unsplash.com/photo-1445116572660-236099ec97a0?w=600',
      ),
      TransactionProductModel(
        id: 2,
        sku: 'TKMP-P002',
        nama: 'Cappuccino',
        kategori: 'Minuman',
        harga: 28000,
        stok: 30,
        imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600',
      ),
      TransactionProductModel(
        id: 3,
        sku: 'TKMP-P003',
        nama: 'Matcha Latte',
        kategori: 'Minuman',
        harga: 30000,
        stok: 25,
        imageUrl: 'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?w=600',
      ),
      TransactionProductModel(
        id: 4,
        sku: 'TKMP-P004',
        nama: 'Roti Cokelat',
        kategori: 'Makanan',
        harga: 18000,
        stok: 40,
        imageUrl: 'https://images.unsplash.com/photo-1483695028939-5bb13f8648b0?w=600',
      ),
      TransactionProductModel(
        id: 5,
        sku: 'TKMP-P005',
        nama: 'Croissant Butter',
        kategori: 'Makanan',
        harga: 25000,
        stok: 20,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab794f4afe5a?w=600',
      ),
      TransactionProductModel(
        id: 6,
        sku: 'TKMP-P006',
        nama: 'Es Teh Lemon',
        kategori: 'Minuman',
        harga: 15000,
        stok: 100,
        imageUrl: 'https://images.unsplash.com/photo-1499638673689-79a0b5115d87?w=600',
      ),
      TransactionProductModel(
        id: 7,
        sku: 'TKMP-P007',
        nama: 'Keripik Singkong',
        kategori: 'Camilan',
        harga: 12000,
        stok: 75,
        imageUrl: 'https://images.unsplash.com/photo-1621447504864-d8686e12698c?w=600',
      ),
      TransactionProductModel(
        id: 8,
        sku: 'TKMP-P008',
        nama: 'Air Mineral',
        kategori: 'Minuman',
        harga: 8000,
        stok: 200,
        imageUrl: 'https://images.unsplash.com/photo-1564419430470-8d3f2d7d71af?w=600',
      ),
      TransactionProductModel(
        id: 9,
        sku: 'TKMP-P009',
        nama: 'Sandwich Tuna',
        kategori: 'Makanan',
        harga: 32000,
        stok: 15,
        imageUrl: 'https://images.unsplash.com/photo-1539252554453-80ab65ce3586?w=600',
      ),
      TransactionProductModel(
        id: 10,
        sku: 'TKMP-P010',
        nama: 'Donat Gula',
        kategori: 'Camilan',
        harga: 14000,
        stok: 45,
        imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=600',
      ),
    ];
  }
}
