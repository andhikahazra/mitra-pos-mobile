import 'package:dartz/dartz.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/data/incoming_goods/models/supplier_model.dart';

abstract class IncomingGoodsRepository {
  Future<Either<Failure, List<SupplierModel>>> getSuppliers();
  Future<Either<Failure, Map<String, dynamic>>> saveIncomingGoods(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> getIncomingGoods({int page = 1});
}
