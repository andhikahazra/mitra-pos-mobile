import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/domain/home/entities/dashboard_stats.dart';
import 'package:mitrapos/domain/home/entities/performance_data.dart';
import 'package:mitrapos/domain/home/entities/store_info.dart';
import 'package:mitrapos/domain/home/usecases/get_dashboard_data.dart';

part 'home_event.dart';
part 'home_state.dart';

// UBAH: Hilangkan autoDispose agar state tetap terjaga dan tidak memicu loop request
final homeControllerProvider = StateNotifierProvider<HomeBloc, HomeState>((ref) {
  return getIt<HomeBloc>();
});

@injectable
class HomeBloc extends StateNotifier<HomeState> {
  final GetDashboardData getDashboardData;

  HomeBloc({
    required this.getDashboardData,
  }) : super(HomeInitial());

  Future<void> add(HomeEvent event) async {
    if (event is LoadDashboard) {
      await _onLoadDashboard(event);
      return;
    }

    if (event is ChangePeriod) {
      await _onChangePeriod(event);
      return;
    }

    if (event is RefreshDashboard) {
      await _onRefreshDashboard(event);
    }
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
  ) async {
    // GUARD: Jika sudah ada data atau sedang loading, jangan request lagi
    if (state is HomeLoading) return;
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      if (currentState.currentPeriod == event.period) return;
    }

    state = HomeLoading();

    final result = await getDashboardData(event.period);

    result.fold(
      (failure) => state = HomeError(failure.message),
      (data) => state = HomeLoaded(
        stats: data.stats,
        performanceData: data.performanceData,
        storeInfo: data.storeInfo,
        currentPeriod: event.period,
      ),
    );
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      if (currentState.currentPeriod == event.period) return;

      final result = await getDashboardData(event.period);

      result.fold(
        (failure) => state = HomeError(failure.message),
        (data) => state = currentState.copyWith(
          stats: data.stats,
          performanceData: data.performanceData,
          storeInfo: data.storeInfo,
          currentPeriod: event.period,
        ),
      );
    } else {
      await _onLoadDashboard(LoadDashboard(event.period));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
  ) async {
    String currentPeriod = 'today';
    if (state is HomeLoaded) {
      currentPeriod = (state as HomeLoaded).currentPeriod;
    }
    
    state = HomeLoading();
    final result = await getDashboardData(currentPeriod);
    result.fold(
      (failure) => state = HomeError(failure.message),
      (data) => state = HomeLoaded(
        stats: data.stats,
        performanceData: data.performanceData,
        storeInfo: data.storeInfo,
        currentPeriod: currentPeriod,
      ),
    );
  }
}
