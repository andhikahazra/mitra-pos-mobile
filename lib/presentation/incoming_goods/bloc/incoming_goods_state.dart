part of 'incoming_goods_controller.dart';

class IncomingGoodsState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final bool isSuccess;
  final List<SupplierModel> suppliers;
  final List<Map<String, dynamic>> incomingGoods; // Tambahkan list untuk riwayat
  final String? errorMessage;

  const IncomingGoodsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.suppliers = const [],
    this.incomingGoods = const [],
    this.errorMessage,
  });

  IncomingGoodsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isSuccess,
    List<SupplierModel>? suppliers,
    List<Map<String, dynamic>>? incomingGoods,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IncomingGoodsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      suppliers: suppliers ?? this.suppliers,
      incomingGoods: incomingGoods ?? this.incomingGoods,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, isSubmitting, isSuccess, suppliers, incomingGoods, errorMessage];
}

class IncomingGoodsInitial extends IncomingGoodsState {
  const IncomingGoodsInitial();
}
