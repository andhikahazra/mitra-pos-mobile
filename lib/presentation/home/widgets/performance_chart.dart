import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/utils/currency_formatter.dart';
import 'package:mitrapos/domain/home/entities/performance_data.dart';

/// Performance chart widget - Ultra Light version to prevent GPU Crash
class PerformanceChart extends StatelessWidget {
  final List<PerformanceData> data;

  const PerformanceChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Pastikan data tidak kosong
    if (data.isEmpty) return const SizedBox.shrink();

    final chartData = data.length > 7 ? data.sublist(data.length - 7) : data;

    final maxSales = chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    // Gunakan buffer 20%
    final maxY = (maxSales == 0) ? 100.0 : maxSales * 1.2;
    
    // Interval grid sangat sederhana (hanya 3 garis: bawah, tengah, atas)
    final gridInterval = maxY / 3;



    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.border,
        ),
        // Tanpa BoxShadow untuk menghemat GPU
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Performa',
                style: AppTypePairing.headlineLg(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: gridInterval,
getDrawingHorizontalLine: (value) => FlLine(
                        color: context.border,
                        strokeWidth: 1,
                      ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < chartData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              chartData[index].day,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: maxY,
                barGroups: chartData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        width: 16,
                        color: context.indigoPrimary,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        // Matikan backDrawRodData untuk meringankan draw call
                        backDrawRodData: BackgroundBarChartRodData(show: false),
                      ),
                    ],
                  );
                }).toList(),
                // Sederhanakan touch data
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => context.surface,
                    tooltipRoundedRadius: 8,
                    tooltipBorder: BorderSide(color: context.border, width: 0.5),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        CurrencyFormatter.format(rod.toY),
                        AppTypePairing.bodySm(weight: FontWeight.w700),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
