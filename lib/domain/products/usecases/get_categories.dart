import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/domain/usecase.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/products/entities/category.dart';
import 'package:mitrapos/domain/products/repositories/products_repository.dart';

@lazySingleton
class GetCategories implements UseCase<List<Category>, NoParams> {
  final ProductsRepository _repository;

  GetCategories(this._repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) {
    return _repository.getCategories();
  }
}
