import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/data/incoming_goods/models/supplier_model.dart';
import 'package:mitrapos/domain/incoming_goods/repositories/incoming_goods_repository.dart';

@injectable
class GetSuppliers {
  final IncomingGoodsRepository repository;

  GetSuppliers(this.repository);

  Future<Either<Failure, List<SupplierModel>>> call() {
    return repository.getSuppliers();
  }
}
