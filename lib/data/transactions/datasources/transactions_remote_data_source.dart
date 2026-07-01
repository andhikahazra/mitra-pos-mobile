import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/network/dio_client.dart';
import 'package:mitrapos/data/transactions/models/transaction_product_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionProductModel>> getProdukTransaksi();
  Future<Map<String, dynamic>> saveTransaction(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getSettings();
  Future<List<Map<String, dynamic>>> getCustomerHistory();
}

@LazySingleton(as: TransactionsRemoteDataSource)
class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  final DioClient _dioClient;

  TransactionsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<TransactionProductModel>> getProdukTransaksi() async {
    final response = await _dioClient.get(
      '/products',
      queryParameters: {'per_page': 100},
    );
    final List data = response.data['data']['data'];
    return data.map((item) => TransactionProductModel.fromJson(item)).toList();
  }

  @override
  Future<Map<String, dynamic>> saveTransaction(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/transactions', data: data);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    final response = await _dioClient.get('/settings');
    return response.data;
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerHistory() async {
    final response = await _dioClient.get('/customers/history');
    final List data = response.data['data'];
    return data.cast<Map<String, dynamic>>();
  }
}
