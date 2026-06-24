import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/incoming_goods/repositories/incoming_goods_repository.dart';

@injectable
class SaveIncomingGoods {
  final IncomingGoodsRepository repository;

  SaveIncomingGoods(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(Map<String, dynamic> data) {
    return repository.saveIncomingGoods(data);
  }
}
