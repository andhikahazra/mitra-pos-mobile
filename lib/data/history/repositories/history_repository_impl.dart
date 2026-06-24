import 'package:injectable/injectable.dart';
import 'package:mitrapos/data/history/datasources/history_remote_data_source.dart';
import 'package:mitrapos/domain/history/entities/history_transaction.dart';
import 'package:mitrapos/domain/history/repositories/history_repository.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource _remoteDataSource;

  HistoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<HistoryTransaction>> getHistory({
    String range = 'all',
    DateTime? date,
    int limit = 15,
    int page = 1,
  }) async {
    final String? dateString = date?.toIso8601String().split('T')[0];
    return await _remoteDataSource.getHistory(
      range: range,
      date: dateString,
      limit: limit,
    );
  }

  @override
  Future<void> settleTransaction(int id, String method, {double? biayaAdmin}) async {
    await _remoteDataSource.settleTransaction(id, method, biayaAdmin: biayaAdmin);
  }
}
