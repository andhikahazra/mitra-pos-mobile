import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/network/dio_client.dart';
import 'package:mitrapos/data/incoming_goods/models/supplier_model.dart';

abstract class IncomingGoodsRemoteDataSource {
  Future<List<SupplierModel>> getSuppliers();
  Future<Map<String, dynamic>> saveIncomingGoods(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getIncomingGoods({int page = 1});
}

@LazySingleton(as: IncomingGoodsRemoteDataSource)
class IncomingGoodsRemoteDataSourceImpl implements IncomingGoodsRemoteDataSource {
  final DioClient _dioClient;

  IncomingGoodsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<SupplierModel>> getSuppliers() async {
    final response = await _dioClient.get('/suppliers');
    final List data = response.data['data'];
    return data.map((item) => SupplierModel.fromJson(item)).toList();
  }

  @override
  Future<Map<String, dynamic>> saveIncomingGoods(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/incoming-goods', data: data);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getIncomingGoods({int page = 1}) async {
    final response = await _dioClient.get(
      '/incoming-goods',
      queryParameters: {'page': page},
    );
    return response.data;
  }
}
