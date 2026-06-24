import 'package:mitrapos/domain/home/entities/dashboard_stats.dart';

/// Dashboard statistics model
class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.views,
    required super.viewsGrowth,
    required super.visits,
    required super.visitsGrowth,
    required super.orders,
    required super.ordersGrowth,
    required super.revenue,
    required super.revenueGrowth,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      views: json['views'] as int,
      viewsGrowth: (json['viewsGrowth'] as num).toDouble(),
      visits: json['visits'] as int,
      visitsGrowth: (json['visitsGrowth'] as num).toDouble(),
      orders: json['orders'] as int,
      ordersGrowth: (json['ordersGrowth'] as num).toDouble(),
      revenue: (json['revenue'] as num).toDouble(),
      revenueGrowth: (json['revenueGrowth'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'views': views,
      'viewsGrowth': viewsGrowth,
      'visits': visits,
      'visitsGrowth': visitsGrowth,
      'orders': orders,
      'ordersGrowth': ordersGrowth,
      'revenue': revenue,
      'revenueGrowth': revenueGrowth,
    };
  }
}
