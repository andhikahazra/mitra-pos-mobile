import 'package:equatable/equatable.dart';
import 'package:mitrapos/domain/home/entities/dashboard_stats.dart';
import 'package:mitrapos/domain/home/entities/performance_data.dart';
import 'package:mitrapos/domain/home/entities/store_info.dart';

class DashboardData extends Equatable {
  final DashboardStats stats;
  final List<PerformanceData> performanceData;
  final StoreInfo storeInfo;

  const DashboardData({
    required this.stats,
    required this.performanceData,
    required this.storeInfo,
  });

  @override
  List<Object?> get props => [stats, performanceData, storeInfo];
}
