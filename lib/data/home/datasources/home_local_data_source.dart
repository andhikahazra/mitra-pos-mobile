import 'package:mitrapos/data/home/models/dashboard_stats_model.dart';
import 'package:mitrapos/data/home/models/performance_data_model.dart';

/// Local data source for home feature
/// This simulates data that would come from an API
abstract class HomeLocalDataSource {
  Future<DashboardStatsModel> getDashboardStats(String period);
  Future<List<PerformanceDataModel>> getPerformanceData(String period);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<DashboardStatsModel> getDashboardStats(String period) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 120));

    // Mock data - Replace with actual API call later
    return const DashboardStatsModel(
      views: 128,
      viewsGrowth: 12,
      visits: 6,
      visitsGrowth: 1,
      orders: 3,
      ordersGrowth: 1,
      revenue: 3280,
      revenueGrowth: 8,
    );
  }

  @override
  Future<List<PerformanceDataModel>> getPerformanceData(String period) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 120));

    // Mock data for chart - Replace with actual API call later
    final now = DateTime.now();
    return [
      PerformanceDataModel(
        day: 'Mon',
        value: 12,
        date: now.subtract(const Duration(days: 6)),
      ),
      PerformanceDataModel(
        day: 'Tue',
        value: 18,
        date: now.subtract(const Duration(days: 5)),
      ),
      PerformanceDataModel(
        day: 'Wed',
        value: 15,
        date: now.subtract(const Duration(days: 4)),
      ),
      PerformanceDataModel(
        day: 'Thu',
        value: 22,
        date: now.subtract(const Duration(days: 3)),
      ),
      PerformanceDataModel(
        day: 'Fri',
        value: 28,
        date: now.subtract(const Duration(days: 2)),
      ),
      PerformanceDataModel(
        day: 'Sat',
        value: 19,
        date: now.subtract(const Duration(days: 1)),
      ),
      PerformanceDataModel(
        day: 'Sun',
        value: 14,
        date: now,
      ),
    ];
  }
}
