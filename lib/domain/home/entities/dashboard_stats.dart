import 'package:equatable/equatable.dart';

/// Dashboard statistics entity
class DashboardStats extends Equatable {
  final int views;
  final double viewsGrowth;
  final int visits;
  final double visitsGrowth;
  final int orders;
  final double ordersGrowth;
  final double revenue;
  final double revenueGrowth;

  const DashboardStats({
    required this.views,
    required this.viewsGrowth,
    required this.visits,
    required this.visitsGrowth,
    required this.orders,
    required this.ordersGrowth,
    required this.revenue,
    required this.revenueGrowth,
  });

  @override
  List<Object?> get props => [
        views,
        viewsGrowth,
        visits,
        visitsGrowth,
        orders,
        ordersGrowth,
        revenue,
        revenueGrowth,
      ];
}
