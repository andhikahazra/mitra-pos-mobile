import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/transactions/repositories/transactions_repository.dart';

@lazySingleton
class GetCustomerHistory {
  final TransactionsRepository repository;

  GetCustomerHistory(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() async {
    return await repository.getCustomerHistory();
  }
}
