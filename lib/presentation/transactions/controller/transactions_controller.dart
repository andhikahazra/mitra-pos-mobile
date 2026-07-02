import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/transactions/entities/transaction_product.dart';
import 'package:mitrapos/domain/transactions/usecases/get_transaction_products.dart';
import 'package:mitrapos/domain/transactions/usecases/save_transaction.dart';
import 'package:mitrapos/domain/transactions/usecases/get_customer_history.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

final transactionsControllerProvider =
    StateNotifierProvider.autoDispose<TransactionsController, TransactionsState>(
  (ref) => throw UnimplementedError('Override transactionsControllerProvider in a ProviderScope'),
);

class TransactionsController extends StateNotifier<TransactionsState> {
  final GetTransactionProducts getTransactionProducts;
  final SaveTransaction saveTransaction;
  final GetCustomerHistory getCustomerHistory;

  TransactionsController({
    required this.getTransactionProducts,
    required this.saveTransaction,
    required this.getCustomerHistory,
  }) : super(const TransactionsState());

  Future<void> add(TransactionsEvent event) async {
    if (event is LoadProdukTransaksi) {
      await _onLoadProdukTransaksi(event);
      return;
    }

    if (event is CariProdukTransaksi) {
      _onCariProdukTransaksi(event);
      return;
    }

    if (event is FilterKategoriTransaksi) {
      _onFilterKategoriTransaksi(event);
      return;
    }

    if (event is TambahProdukKeranjang) {
      _onTambahProdukKeranjang(event);
      return;
    }

    if (event is KurangProdukKeranjang) {
      _onKurangProdukKeranjang(event);
      return;
    }

    if (event is HapusProdukKeranjang) {
      _onHapusProdukKeranjang(event);
      return;
    }

    if (event is SetQtyProdukKeranjang) {
      _onSetQtyProdukKeranjang(event);
      return;
    }

    if (event is ResetKeranjang) {
      _onResetKeranjang(event);
      return;
    }

    if (event is SubmitTransaksi) {
      await _onSubmitTransaksi(event);
      return;
    }

    if (event is ResetTransactionStatus) {
      _onResetTransactionStatus(event);
    }
  }

  Future<void> _onLoadProdukTransaksi(
    LoadProdukTransaksi event,
  ) async {
    if (state.allProducts.isEmpty) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }

    final results = await Future.wait([
      getTransactionProducts(),
      getTransactionProducts.repository.getSettings(),
      getCustomerHistory(),
    ]);

    final productsResult = results[0] as Either<Failure, List<TransactionProduct>>;
    final settingsResult = results[1] as Either<Failure, Map<String, dynamic>>;
    final historyResult = results[2] as Either<Failure, List<Map<String, dynamic>>>;

    // Handle products
    productsResult.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (products) {
        state = state.copyWith(
          isLoading: false,
          allProducts: products,
          visibleProducts: _applyFilters(
            allProducts: products,
            keyword: state.searchKeyword,
            kategori: state.selectedKategori,
          ),
          clearError: true,
        );
      },
    );

    // Handle settings
    settingsResult.fold(
      (failure) => null, // Ignore settings error for now, or log it
      (settings) => state = state.copyWith(appSettings: settings['data']),
    );

    // Handle history
    historyResult.fold(
      (failure) => null,
      (history) => state = state.copyWith(customerHistory: history),
    );
  }

  void _onCariProdukTransaksi(
    CariProdukTransaksi event,
  ) {
    state =
      state.copyWith(
        searchKeyword: event.keyword,
        visibleProducts: _applyFilters(
          allProducts: state.allProducts,
          keyword: event.keyword,
          kategori: state.selectedKategori,
        ),
      );
  }

  void _onFilterKategoriTransaksi(
    FilterKategoriTransaksi event,
  ) {
    final nextKategori = state.selectedKategori == event.kategori ? 'Semua' : event.kategori;

    state =
      state.copyWith(
        selectedKategori: nextKategori,
        visibleProducts: _applyFilters(
          allProducts: state.allProducts,
          keyword: state.searchKeyword,
          kategori: nextKategori,
        ),
      );
  }

  void _onTambahProdukKeranjang(
    TambahProdukKeranjang event,
  ) {
    final currentQty = state.cartItems[event.produk.id] ?? 0;
    
    if (currentQty + 1 > event.produk.stok) {
      state = state.copyWith(errorMessage: 'Stok tidak mencukupi');
      return;
    }

    final updated = Map<int, int>.from(state.cartItems);
    updated.update(event.produk.id, (qty) => qty + 1, ifAbsent: () => 1);
    state = state.copyWith(cartItems: updated);
  }

  void _onKurangProdukKeranjang(
    KurangProdukKeranjang event,
  ) {
    if (!state.cartItems.containsKey(event.productId)) return;

    final updated = Map<int, int>.from(state.cartItems);
    final current = updated[event.productId] ?? 0;

    if (current <= 1) {
      updated.remove(event.productId);
    } else {
      updated[event.productId] = current - 1;
    }

    state = state.copyWith(cartItems: updated);
  }

  void _onHapusProdukKeranjang(
    HapusProdukKeranjang event,
  ) {
    if (!state.cartItems.containsKey(event.productId)) return;
    final updated = Map<int, int>.from(state.cartItems)..remove(event.productId);
    state = state.copyWith(cartItems: updated);
  }

  void _onSetQtyProdukKeranjang(
    SetQtyProdukKeranjang event,
  ) {
    final product = state.allProducts.firstWhere((p) => p.id == event.productId);
    if (event.qty > product.stok) {
      state = state.copyWith(errorMessage: 'Stok tidak mencukupi (Max: ${product.stok})');
      return;
    }

    final updated = Map<int, int>.from(state.cartItems);

    if (event.qty <= 0) {
      updated.remove(event.productId);
    } else {
      updated[event.productId] = event.qty;
    }

    state = state.copyWith(cartItems: updated);
  }

  void _onResetKeranjang(
    ResetKeranjang event,
  ) {
    state = state.copyWith(cartItems: const {});
  }

  Future<void> _onSubmitTransaksi(SubmitTransaksi event) async {
    if (state.cartItems.isEmpty) {
      state = state.copyWith(errorMessage: 'Keranjang masih kosong');
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true, isSuccess: false);

    // Map cart items to payload format
    state = state.copyWith(isSubmitting: true, lastUangCustomer: event.uangCustomer);
    final payload = {
      'nama_pelanggan': event.namaPelanggan,
      'no_hp_pelanggan': event.noHpPelanggan,
      'metode_pembayaran': event.metodePembayaran,
      'biaya_admin': event.biayaAdmin,
      'catatan': event.catatan ?? '',
      'items': state.cartItems.entries.map((e) {
        final product = state.allProducts.firstWhere((p) => p.id == e.key);
        return {
          'produk_id': e.key,
          'jumlah': e.value,
          'harga': product.harga,
        };
      }).toList(),
    };

    final result = await saveTransaction(payload);
    result.fold(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ),
      (response) {
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          lastTransactionResponse: response,
          clearError: true,
        );
        add(const ResetKeranjang());
      },
    );
  }

  void _onResetTransactionStatus(ResetTransactionStatus event) {
    state = state.copyWith(isSuccess: false, clearError: true, lastTransactionResponse: null);
  }

  List<TransactionProduct> _applyFilters({
    required List<TransactionProduct> allProducts,
    required String keyword,
    required String kategori,
  }) {
    final normalizedKeyword = keyword.trim().toLowerCase();

    return allProducts.where((item) {
      final kategoriMatch = kategori == 'Semua' || item.kategori == kategori;
      final keywordMatch = normalizedKeyword.isEmpty ||
          item.nama.toLowerCase().contains(normalizedKeyword) ||
          item.kategori.toLowerCase().contains(normalizedKeyword) ||
          item.sku.toLowerCase().contains(normalizedKeyword); // Also search by SKU
      return kategoriMatch && keywordMatch;
    }).toList();
  }
}
