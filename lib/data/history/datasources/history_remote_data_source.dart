import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/network/dio_client.dart';
import 'package:mitrapos/data/history/models/history_transaction_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryTransactionModel>> getHistory({
    String range = 'all',
    String? date,
    int limit = 15,
  });

  Future<void> settleTransaction(int id, String method, {double? biayaAdmin});
}

@LazySingleton(as: HistoryRemoteDataSource)
class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final DioClient _dioClient;

  HistoryRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<HistoryTransactionModel>> getHistory({
    String range = 'all',
    String? date,
    int limit = 15,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'range': range,
      'limit': limit,
    };
    if (date != null) {
      queryParameters['date'] = date;
    }

    final response = await _dioClient.get(
      '/transactions',
      queryParameters: queryParameters,
    );

    final List data = response.data['data']['data'];
    return data.map((item) => HistoryTransactionModel.fromJson(item)).toList();
  }

  @override
  Future<void> settleTransaction(int id, String method, {double? biayaAdmin}) async {
    final Map<String, dynamic> data = {'metode_pembayaran': method};
    if (biayaAdmin != null) {
      data['biaya_admin'] = biayaAdmin;
    }
    
    await _dioClient.patch(
      '/transactions/$id/settle',
      data: data,
    );
  }
}
