import 'package:dartz/dartz.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/transactions/entities/transaction_product.dart';

abstract class TransactionsRepository {
  Future<Either<Failure, List<TransactionProduct>>> getProdukTransaksi();
  Future<Either<Failure, Map<String, dynamic>>> saveTransaction(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> getSettings();
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerHistory();
}
