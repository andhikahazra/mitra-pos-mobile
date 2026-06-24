import 'package:dartz/dartz.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/home/entities/dashboard_data.dart';

abstract class HomeRepository {
  Future<Either<Failure, DashboardData>> getDashboardData(String period);
}
