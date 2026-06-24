import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/incoming_goods/repositories/incoming_goods_repository.dart';

@injectable
class GetIncomingGoods {
  final IncomingGoodsRepository repository;

  GetIncomingGoods(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({int page = 1}) {
    return repository.getIncomingGoods(page: page);
  }
}
