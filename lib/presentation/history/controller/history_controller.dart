import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/domain/history/entities/history_transaction.dart';
import 'package:mitrapos/domain/history/repositories/history_repository.dart';
import 'package:mitrapos/data/history/repositories/history_repository_impl.dart';
import 'package:mitrapos/data/history/datasources/history_remote_data_source.dart';
import 'package:mitrapos/core/network/dio_client.dart';

class HistoryState {
  final bool isLoading;
  final List<HistoryTransaction> transactions;
  final String? errorMessage;
  final String activeRange;
  final DateTime? selectedDate;

  HistoryState({
    this.isLoading = false,
    this.transactions = const [],
    this.errorMessage,
    this.activeRange = 'hari',
    this.selectedDate,
  });

  HistoryState copyWith({
    bool? isLoading,
    List<HistoryTransaction>? transactions,
    String? errorMessage,
    String? activeRange,
    DateTime? selectedDate,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
      activeRange: activeRange ?? this.activeRange,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class HistoryController extends StateNotifier<HistoryState> {
  final HistoryRepository _repository;

  HistoryController(this._repository) : super(HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final transactions = await _repository.getHistory(
        range: state.activeRange.toLowerCase(),
        date: state.selectedDate,
      );
      state = state.copyWith(isLoading: false, transactions: transactions);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setRange(String range) {
    state = HistoryState(
      isLoading: state.isLoading,
      transactions: state.transactions,
      errorMessage: state.errorMessage,
      activeRange: range,
    );
    loadHistory();
  }

  void setDate(DateTime? date) {
    if (date != null) {
      state = HistoryState(
        isLoading: state.isLoading,
        transactions: state.transactions,
        errorMessage: state.errorMessage,
        activeRange: 'all',
        selectedDate: date,
      );
    } else {
      state = HistoryState(
        isLoading: state.isLoading,
        transactions: state.transactions,
        errorMessage: state.errorMessage,
        activeRange: state.activeRange,
      );
    }
    loadHistory();
  }

  Future<void> settleTransaction(int id, String method, {double? biayaAdmin}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.settleTransaction(id, method, biayaAdmin: biayaAdmin);
      await loadHistory();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

// Manually providing the repository if injection.config.dart is not updated yet
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final dioClient = getIt<DioClient>();
  final remoteDataSource = HistoryRemoteDataSourceImpl(dioClient);
  return HistoryRepositoryImpl(remoteDataSource);
});

final historyControllerProvider =
    StateNotifierProvider<HistoryController, HistoryState>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryController(repository);
});
