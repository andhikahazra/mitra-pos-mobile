import 'package:mitrapos/domain/history/entities/history_transaction.dart';

abstract class HistoryRepository {
  Future<List<HistoryTransaction>> getHistory({
    String range = 'all',
    DateTime? date,
    int limit = 15,
    int page = 1,
  });

  Future<void> settleTransaction(int id, String method, {double? biayaAdmin});
}
