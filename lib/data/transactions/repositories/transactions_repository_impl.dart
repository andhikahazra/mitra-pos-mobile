import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/data/transactions/datasources/transactions_remote_data_source.dart';
import 'package:mitrapos/domain/transactions/entities/transaction_product.dart';
import 'package:mitrapos/domain/transactions/repositories/transactions_repository.dart';

@LazySingleton(as: TransactionsRepository)
class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource remoteDataSource;

  TransactionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<TransactionProduct>>> getProdukTransaksi() async {
    try {
      final products = await remoteDataSource.getProdukTransaksi();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> saveTransaction(Map<String, dynamic> data) async {
    try {
      final response = await remoteDataSource.saveTransaction(data);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSettings() async {
    try {
      final response = await remoteDataSource.getSettings();
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerHistory() async {
    try {
      final response = await remoteDataSource.getCustomerHistory();
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
