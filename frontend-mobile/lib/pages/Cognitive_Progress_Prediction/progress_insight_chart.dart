import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/Cognitive_Progress_Prediction/cognitive_progress_service.dart';

class ProgressInsightChart extends StatelessWidget {
  final List<StoredProgress> history;

  const ProgressInsightChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text("No insight data available");
    }

    // sort by date (oldest → newest)
    final sorted = [...history]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      spots.add(
        FlSpot(
          i.toDouble(),
          sorted[i].progressPrediction,
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  final date = sorted[index].createdAt;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "${date.day}/${date.month}",
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
