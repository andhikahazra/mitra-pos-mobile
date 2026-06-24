import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/data/products/datasources/product_remote_datasource.dart';
import 'package:mitrapos/data/products/models/category_model.dart';
import 'package:mitrapos/data/products/models/product_model.dart';
import 'package:mitrapos/domain/products/entities/category.dart';
import 'package:mitrapos/domain/products/entities/product.dart';
import 'package:mitrapos/domain/products/repositories/products_repository.dart';

@LazySingleton(as: ProductsRepository)
class ProductsRepositoryImpl implements ProductsRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts({String? search, int? kategoriId}) async {
    try {
      final response = await _remoteDataSource.getProducts(
        search: search,
        kategoriId: kategoriId,
      );
      
      final List data = response['data']['data'];
      final products = data.map((e) => ProductModel.fromJson(e)).toList();
      
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductDetail(int id) async {
    try {
      final response = await _remoteDataSource.getProductDetail(id);
      final product = ProductModel.fromJson(response['data']);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final response = await _remoteDataSource.getCategories();
      final List data = response['data'];
      final categories = data.map((e) => CategoryModel.fromJson(e)).toList();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
