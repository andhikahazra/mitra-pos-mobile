import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/transactions/repositories/transactions_repository.dart';

@injectable
class SaveTransaction {
  final TransactionsRepository repository;

  SaveTransaction(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(Map<String, dynamic> data) {
    return repository.saveTransaction(data);
  }
}
