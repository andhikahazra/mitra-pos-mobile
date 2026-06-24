part of 'home_controller.dart';

/// Home states
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {}

/// Loading state
class HomeLoading extends HomeState {}

/// Loaded state
class HomeLoaded extends HomeState {
  final DashboardStats stats;
  final List<PerformanceData> performanceData;
  final StoreInfo storeInfo;
  final String currentPeriod;

  const HomeLoaded({
    required this.stats,
    required this.performanceData,
    required this.storeInfo,
    required this.currentPeriod,
  });

  @override
  List<Object?> get props => [stats, performanceData, storeInfo, currentPeriod];

  HomeLoaded copyWith({
    DashboardStats? stats,
    List<PerformanceData>? performanceData,
    StoreInfo? storeInfo,
    String? currentPeriod,
  }) {
    return HomeLoaded(
      stats: stats ?? this.stats,
      performanceData: performanceData ?? this.performanceData,
      storeInfo: storeInfo ?? this.storeInfo,
      currentPeriod: currentPeriod ?? this.currentPeriod,
    );
  }
}

/// Error state
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
