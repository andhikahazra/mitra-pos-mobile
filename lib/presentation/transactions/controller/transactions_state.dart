part of 'transactions_controller.dart';

class TransactionsState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final bool isSuccess;
  final List<TransactionProduct> allProducts;
  final List<TransactionProduct> visibleProducts;
  final String selectedKategori;
  final String searchKeyword;
  final Map<int, int> cartItems;
  final Map<String, dynamic>? appSettings;
  final String? errorMessage;
  final Map<String, dynamic>? lastTransactionResponse;
  final int? lastUangCustomer;
  final List<Map<String, dynamic>> customerHistory;

  const TransactionsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.allProducts = const [],
    this.visibleProducts = const [],
    this.selectedKategori = 'Semua',
    this.searchKeyword = '',
    this.cartItems = const {},
    this.appSettings,
    this.errorMessage,
    this.lastTransactionResponse,
    this.lastUangCustomer,
    this.customerHistory = const [],
  });

  TransactionsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isSuccess,
    List<TransactionProduct>? allProducts,
    List<TransactionProduct>? visibleProducts,
    String? selectedKategori,
    String? searchKeyword,
    Map<int, int>? cartItems,
    Map<String, dynamic>? appSettings,
    String? errorMessage,
    Map<String, dynamic>? lastTransactionResponse,
    int? lastUangCustomer,
    List<Map<String, dynamic>>? customerHistory,
    bool clearError = false,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      allProducts: allProducts ?? this.allProducts,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      selectedKategori: selectedKategori ?? this.selectedKategori,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      cartItems: cartItems ?? this.cartItems,
      appSettings: appSettings ?? this.appSettings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastTransactionResponse: lastTransactionResponse ?? this.lastTransactionResponse,
      lastUangCustomer: lastUangCustomer ?? this.lastUangCustomer,
      customerHistory: customerHistory ?? this.customerHistory,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        isSuccess,
        allProducts,
        visibleProducts,
        selectedKategori,
        searchKeyword,
        cartItems,
        appSettings,
        errorMessage,
        lastTransactionResponse,
        lastUangCustomer,
        customerHistory,
      ];
}
