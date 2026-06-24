part of 'product_controller.dart';

class ProductState extends Equatable {
  final bool isLoading;
  final List<Product> products;
  final List<Category> categories;
  final String? errorMessage;
  final String searchQuery;
  final int? categoryFilter;

  const ProductState({
    this.isLoading = false,
    this.products = const [],
    this.categories = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.categoryFilter,
  });

  ProductState copyWith({
    bool? isLoading,
    List<Product>? products,
    List<Category>? categories,
    String? errorMessage,
    String? searchQuery,
    int? categoryFilter,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }

  @override
  List<Object?> get props => [isLoading, products, categories, errorMessage, searchQuery, categoryFilter];
}
