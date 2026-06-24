import 'package:mitrapos/domain/home/entities/performance_data.dart';

/// Performance data model
class PerformanceDataModel extends PerformanceData {
  const PerformanceDataModel({
    required super.day,
    required super.value,
    required super.date,
  });

  factory PerformanceDataModel.fromJson(Map<String, dynamic> json) {
    return PerformanceDataModel(
      day: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'value': value,
      'date': date.toIso8601String(),
    };
  }
}
