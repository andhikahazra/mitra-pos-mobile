import 'package:equatable/equatable.dart';

/// Performance data point entity
class PerformanceData extends Equatable {
  final String day;
  final double value;
  final DateTime date;

  const PerformanceData({
    required this.day,
    required this.value,
    required this.date,
  });

  @override
  List<Object?> get props => [day, value, date];
}
