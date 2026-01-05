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

  String _fmtShortMonth(DateTime d) {
    const m = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return m[(d.month - 1).clamp(0, 11)];
  }

  List<Map<String, dynamic>> _sortedHistory() {
    final cleaned = <Map<String, dynamic>>[];
    for (final item in history) {
      final score = _safeScore(item);
      final dt = _safeDate(item);
      if (score == null || dt == null) continue;
      cleaned.add({"date": dt, "score": score});
    }
    cleaned.sort(
      (a, b) =>
          (a["date"] as DateTime).compareTo(b["date"] as DateTime),
    );
    return cleaned;
  }

  String _trendLabel(List<Map<String, dynamic>> points) {
    if (points.length < 2) return "Stable";
    final diff =
        (points.last["score"] as double) -
        (points.first["score"] as double);
    if (diff > 2) return "Improving";
    if (diff < -2) return "Declining";
    return "Stable";
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFF2E4D4);
    const accent = Color(0xFFB98A54);
    const textDark = Color(0xFF6B4B2E);

    if (loading) {
      return Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        height: 190,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final points = _sortedHistory();

    if (points.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text("Not enough data"),
      );
    }

    final trend = _trendLabel(points);

    final spots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i]["score"] as double),
    );

    final ys = spots.map((e) => e.y).toList();
    double minY = ys.reduce((a, b) => a < b ? a : b);
    double maxY = ys.reduce((a, b) => a > b ? a : b);

    final pad = ((maxY - minY) * 0.25).clamp(2.0, 12.0);
    minY = (minY - pad).clamp(0, 100);
    maxY = (maxY + pad).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topRow(trend, onRefresh, accent, textDark),
          const SizedBox(height: 12),

          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 3,
                ),

                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Color(0x55B98A54)),
                    bottom: BorderSide(color: Color(0x55B98A54)),
                  ),
                ),

                // ✅ Y-AXIS VALUES ENABLED HERE
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
                      interval: (maxY - minY) / 3,
                      reservedSize: 36,
                      getTitlesWidget: (value, _) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx >= points.length) return const SizedBox();
                        final dt = points[idx]["date"] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _fmtShortMonth(dt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 2.5,
                    color: accent,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topRow(
    String trend,
    VoidCallback onRefresh,
    Color accent,
    Color textDark,
  ) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Next 14 Days",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          trend,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
        IconButton(
          icon: Icon(Icons.refresh, size: 18, color: accent),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}
