import 'package:dartz/dartz.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/products/entities/category.dart';
import 'package:mitrapos/domain/products/entities/product.dart';

abstract class ProductsRepository {
  Future<Either<Failure, List<Product>>> getProducts({String? search, int? kategoriId});
  Future<Either<Failure, Product>> getProductDetail(int id);
  Future<Either<Failure, List<Category>>> getCategories();
}

