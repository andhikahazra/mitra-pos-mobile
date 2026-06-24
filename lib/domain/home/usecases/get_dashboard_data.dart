import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/home/entities/dashboard_data.dart';
import 'package:mitrapos/domain/home/repositories/home_repository.dart';

@injectable
class GetDashboardData {
  final HomeRepository repository;

  GetDashboardData(this.repository);

  Future<Either<Failure, DashboardData>> call(String period) {
    return repository.getDashboardData(period);
  }
}
