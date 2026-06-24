import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/data/incoming_goods/datasources/incoming_goods_remote_datasource.dart';
import 'package:mitrapos/data/incoming_goods/models/supplier_model.dart';
import 'package:mitrapos/domain/incoming_goods/repositories/incoming_goods_repository.dart';

@LazySingleton(as: IncomingGoodsRepository)
class IncomingGoodsRepositoryImpl implements IncomingGoodsRepository {
  final IncomingGoodsRemoteDataSource remoteDataSource;

  IncomingGoodsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SupplierModel>>> getSuppliers() async {
    try {
      final result = await remoteDataSource.getSuppliers();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> saveIncomingGoods(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.saveIncomingGoods(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getIncomingGoods({int page = 1}) async {
    try {
      final result = await remoteDataSource.getIncomingGoods(page: page);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
