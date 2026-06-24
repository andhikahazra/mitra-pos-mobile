import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/data/incoming_goods/models/supplier_model.dart';
import 'package:mitrapos/domain/incoming_goods/usecases/get_incoming_goods.dart';
import 'package:mitrapos/domain/incoming_goods/usecases/get_suppliers.dart';
import 'package:mitrapos/domain/incoming_goods/usecases/save_incoming_goods.dart';

part 'incoming_goods_state.dart';

final incomingGoodsControllerProvider = StateNotifierProvider.autoDispose<IncomingGoodsController, IncomingGoodsState>((ref) {
  return getIt<IncomingGoodsController>();
});

@injectable
class IncomingGoodsController extends StateNotifier<IncomingGoodsState> {
  final GetSuppliers getSuppliers;
  final SaveIncomingGoods saveIncomingGoods;
  final GetIncomingGoods getIncomingGoods;

  IncomingGoodsController({
    required this.getSuppliers,
    required this.saveIncomingGoods,
    required this.getIncomingGoods,
  }) : super(const IncomingGoodsInitial());

  Future<void> loadSuppliers() async {
    state = state.copyWith(isLoading: true);
    
    final result = await getSuppliers();
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (suppliers) => state = state.copyWith(isLoading: false, suppliers: suppliers),
    );
  }



  Future<void> loadIncomingGoodsHistory() async {
    if (!mounted) return; // Ensure the widget is still mounted
    state = state.copyWith(isLoading: true);

    final result = await getIncomingGoods();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (response) {
        if (!mounted) return; // Check again before updating state
        final List<dynamic> rawList = response['data']?['data'] ?? [];
        final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(rawList);
        state = state.copyWith(isLoading: false, incomingGoods: items);
      },
    );
  }

  Future<void> submitIncomingGoods(Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true, isSuccess: false);
    
    final result = await saveIncomingGoods(data);
    
    result.fold(
      (failure) => state = state.copyWith(isSubmitting: false, errorMessage: failure.message),
      (response) {
        state = state.copyWith(isSubmitting: false, isSuccess: true);
        // Refresh history after success
        loadIncomingGoodsHistory();
      },
    );
  }

  void resetStatus() {
    state = state.copyWith(
      isSuccess: false,
      clearError: true,
      isSubmitting: false,
    );
  }
}
