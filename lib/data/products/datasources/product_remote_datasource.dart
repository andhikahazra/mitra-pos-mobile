import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/network/dio_client.dart';

abstract class ProductRemoteDataSource {
  Future<Map<String, dynamic>> getProducts({String? search, int? kategoriId, int page = 1});
  Future<Map<String, dynamic>> getProductDetail(int id);
  Future<Map<String, dynamic>> getCategories();
}

@LazySingleton(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> getProducts({String? search, int? kategoriId, int page = 1}) async {
    // Kita buat Map dulu, lalu hapus yang nilainya null agar tidak dikirim ke API
    final params = {
      'search': search,
      'kategori_id': kategoriId,
      'page': page,
    }..removeWhere((key, value) => value == null);

    final response = await _dioClient.get(
      '/products',
      queryParameters: params,
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getProductDetail(int id) async {
    final response = await _dioClient.get('/products/$id');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getCategories() async {
    final response = await _dioClient.get('/categories');
    return response.data;
  }
}
