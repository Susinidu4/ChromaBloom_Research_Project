import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightChartCard extends StatelessWidget {
  final bool loading;
  final String? childId;
  final List<dynamic> history;
  final VoidCallback onRefresh;

  const InsightChartCard({
    super.key,
    required this.loading,
    required this.history,
    required this.onRefresh,
    this.childId,
  });

  // ----------------- helpers -----------------
  double _clampScore(double v) {
    if (v.isNaN || v.isInfinite) return 0;
    if (v < 0) return 0;
    if (v > 100) return 100;
    return v;
  }

  double? _safeScore(dynamic item) {
    final v = item?["progress_prediction"];
    if (v is num) return _clampScore(v.toDouble());
    return null;
  }

  DateTime? _safeDate(dynamic item) {
    final s = item?["createdAt"]?.toString();
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  String _fmtShortDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, "0");
    final mm = d.month.toString().padLeft(2, "0");
    return "$mm/$dd";
  }

  String _fmtDateTime(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")} "
        "${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}";
  }

  List<Map<String, dynamic>> _sortedHistory() {
    final cleaned = <Map<String, dynamic>>[];

    for (final item in history) {
      final score = _safeScore(item);
      final dt = _safeDate(item);
      if (score == null || dt == null) continue;
      cleaned.add({"date": dt, "score": score});
    }

    cleaned.sort((a, b) =>
        (a["date"] as DateTime).compareTo(b["date"] as DateTime));

    return cleaned;
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final points = _sortedHistory();

    if (points.length < 2) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 6),
              Text(
                points.isEmpty
                    ? "No saved predictions yet."
                    : "Need at least 2 saved predictions to draw the chart.",
              ),
              const SizedBox(height: 6),
              Text("Child ID: ${childId ?? "-"}"),
            ],
          ),
        ),
      );
    }

    final spots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i]["score"] as double),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 4),
            Text("Child ID: ${childId ?? "-"}"),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 10,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black12),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        reservedSize: 44,
                        getTitlesWidget: (value, _) {
                          if (value % 10 != 0) return const SizedBox.shrink();
                          return Text(value.toInt().toString(),
                              style: const TextStyle(fontSize: 11));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: points.length <= 6 ? 1 : 2,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _fmtShortDate(points[idx]["date"] as DateTime),
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        return spots.map((s) {
                          final idx = s.x.toInt();
                          final dt = points[idx]["date"] as DateTime;
                          final score = points[idx]["score"] as double;
                          return LineTooltipItem(
                            "${_fmtDateTime(dt)}\nScore: ${score.toStringAsFixed(2)}",
                            const TextStyle(fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Insight Chart",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }
}
