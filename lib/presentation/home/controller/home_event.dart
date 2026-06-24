part of 'home_controller.dart';

/// Home events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard event
class LoadDashboard extends HomeEvent {
  final String period;

  const LoadDashboard(this.period);

  @override
  List<Object?> get props => [period];
}

/// Change period event
class ChangePeriod extends HomeEvent {
  final String period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Refresh dashboard event
class RefreshDashboard extends HomeEvent {
  const RefreshDashboard();
}
