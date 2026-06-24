import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/data/home/datasources/home_remote_data_source.dart';
import 'package:mitrapos/data/home/models/dashboard_stats_model.dart';
import 'package:mitrapos/data/home/models/performance_data_model.dart';
import 'package:mitrapos/data/home/models/store_info_model.dart';
import 'package:mitrapos/domain/home/entities/dashboard_data.dart';
import 'package:mitrapos/domain/home/repositories/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DashboardData>> getDashboardData(String period) async {
    try {
      final response = await remoteDataSource.getDashboardData(period);
      
      final statsData = response['data']['stats'] as Map<String, dynamic>;
      final performanceDataList = response['data']['performanceData'] as List<dynamic>;
      final storeInfoData = response['data']['storeInfo'] as Map<String, dynamic>;

      final stats = DashboardStatsModel.fromJson(statsData);
      final performanceData = performanceDataList
          .map((item) => PerformanceDataModel.fromJson(item as Map<String, dynamic>))
          .toList();
      final storeInfo = StoreInfoModel.fromJson(storeInfoData);

      return Right(DashboardData(
        stats: stats,
        performanceData: performanceData,
        storeInfo: storeInfo,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
