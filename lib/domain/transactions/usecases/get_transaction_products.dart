import 'package:dartz/dartz.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/transactions/entities/transaction_product.dart';
import 'package:mitrapos/domain/transactions/repositories/transactions_repository.dart';

class GetTransactionProducts {
  final TransactionsRepository repository;

  GetTransactionProducts(this.repository);

  Future<Either<Failure, List<TransactionProduct>>> call() {
    return repository.getProdukTransaksi();
  }
}
