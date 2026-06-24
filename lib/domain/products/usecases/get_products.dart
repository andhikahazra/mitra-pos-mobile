import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/domain/usecase.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/products/entities/product.dart';
import 'package:mitrapos/domain/products/repositories/products_repository.dart';

@lazySingleton
class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  final ProductsRepository _repository;

  GetProducts(this._repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) {
    return _repository.getProducts(
      search: params.search,
      kategoriId: params.kategoriId,
    );
  }
}

class GetProductsParams {
  final String? search;
  final int? kategoriId;

  GetProductsParams({this.search, this.kategoriId});
}
