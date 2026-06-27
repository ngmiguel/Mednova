import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'dashboard_metrics.dart';

class DashboardWeeklyChart extends StatelessWidget {
  const DashboardWeeklyChart({super.key, required this.data});

  final List<DayMetric> data;

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((d) => d.value).fold<double>(0, (a, b) => a > b ? a : b);
    final top = maxY < 1 ? 4.0 : (maxY + 1).ceilToDouble();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: top,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppColors.glassBorder, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(data[i].label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].value),
              ],
              isCurved: true,
              gradient: AppColors.auroraGradient,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.auroraCyan,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.auroraTeal.withValues(alpha: 0.35),
                    AppColors.auroraTeal.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardStatusPieChart extends StatelessWidget {
  const DashboardStatusPieChart({super.key, required this.counts});

  final Map<String, int> counts;

  static const _colors = [
    AppColors.auroraTeal,
    AppColors.auroraViolet,
    AppColors.success,
    AppColors.auroraGold,
    AppColors.danger,
  ];

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('Aucun RDV', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    final entries = counts.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  for (var i = 0; i < entries.length; i++)
                    PieChartSectionData(
                      value: entries[i].value.toDouble(),
                      color: _colors[i % _colors.length],
                      radius: 52,
                      title: '${((entries[i].value / total) * 100).round()}%',
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _colors[i % _colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${entries[i].key} (${entries[i].value})',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardRiskBarChart extends StatelessWidget {
  const DashboardRiskBarChart({super.key, required this.counts});

  final Map<String, int> counts;

  Color _colorFor(String level) => switch (level.toUpperCase()) {
        'CRITICAL' => AppColors.danger,
        'HIGH' => AppColors.auroraPink,
        'MODERATE' => AppColors.auroraGold,
        'LOW' => AppColors.success,
        _ => AppColors.auroraCyan,
      };

  String _label(String level) => switch (level.toUpperCase()) {
        'CRITICAL' => 'Critique',
        'HIGH' => 'Élevé',
        'MODERATE' => 'Modéré',
        'LOW' => 'Faible',
        _ => level,
      };

  @override
  Widget build(BuildContext context) {
    const order = ['LOW', 'MODERATE', 'HIGH', 'CRITICAL'];
    final items = order.where((k) => (counts[k] ?? 0) > 0).map((k) => MapEntry(k, counts[k]!)).toList();
    if (items.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('Aucune évaluation IA', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    final maxY = items.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppColors.glassBorder, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= items.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _label(items[i].key),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < items.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: items[i].value.toDouble(),
                    width: 22,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        _colorFor(items[i].key).withValues(alpha: 0.6),
                        _colorFor(items[i].key),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
