import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/core/domain/usecase.dart';
import 'package:mitrapos/domain/products/entities/category.dart';
import 'package:mitrapos/domain/products/entities/product.dart';
import 'package:mitrapos/domain/products/usecases/get_categories.dart';
import 'package:mitrapos/domain/products/usecases/get_products.dart';

part 'product_state.dart';

final productControllerProvider = StateNotifierProvider<ProductController, ProductState>((ref) {
  return getIt<ProductController>();
});

@injectable
class ProductController extends StateNotifier<ProductState> {
  final GetProducts _getProducts;
  final GetCategories _getCategories;

  ProductController(this._getProducts, this._getCategories) : super(const ProductState()) {
    fetchCategories();
  }

  Future<void> fetchProducts({String? search, int? kategoriId}) async {
    // Hanya tampilkan loading jika data benar-benar kosong (first load)
    if (state.products.isEmpty) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final result = await _getProducts(GetProductsParams(
      search: search ?? state.searchQuery,
      kategoriId: kategoriId ?? state.categoryFilter,
    ));

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        products: products,
        searchQuery: search ?? state.searchQuery,
        categoryFilter: kategoriId ?? state.categoryFilter,
      ),
    );
  }

  Future<void> fetchCategories() async {
    final result = await _getCategories(NoParams());
    result.fold(
      (failure) => null, // Silent fail for categories
      (categories) => state = state.copyWith(categories: categories),
    );
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    fetchProducts();
  }

  void updateCategory(int? categoryId) {
    state = state.copyWith(categoryFilter: categoryId);
    fetchProducts();
  }
}
