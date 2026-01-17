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
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
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
    // Colors extracted/approximated from the image
    const cardBg = Color(0xFFEEE0D0); // Light beige background
    const stripBg = Color(0xFFE2CBB3); // Darker beige strip
    const axisColor = Color(0xFFBCA686); // Axis line color
    const lineColor = Color(0xFFA68A64); // Chart line & dot color
    const textDark = Color(0xFF5D4037); // Dark brown text
    const trendColor = Color(0xFF9E8360); // Improving text color

    if (loading) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator(color: lineColor)),
      );
    }

    final points = _sortedHistory();

    if (points.length < 2) {
      return Container(
        height: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            "Not enough data",
            style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
          ),
        ),
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

    // Add padding to Y range
    final pad = ((maxY - minY) * 0.3).clamp(5.0, 20.0);
    minY = (minY - pad).clamp(0, 100);
    maxY = (maxY + pad).clamp(0, 100);

    return Container(
      height: 240, // Slightly taller to match aspect ratio
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Main Chart Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 10, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Next 14 Days",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A3B32),
                        ),
                      ),
                      Text(
                        trend,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Spacer before chart
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (points.length - 1).toDouble(),
                        minY: minY,
                        maxY: maxY,

                        // Minimalist grid
                        gridData: FlGridData(show: false),

                        // Stronger Borders for X and Y axis only
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            left: BorderSide(color: axisColor, width: 2),
                            bottom: BorderSide(color: axisColor, width: 2),
                            top: BorderSide.none,
                            right: BorderSide.none,
                          ),
                        ),

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
                              reservedSize: 30, // Space for Y labels
                              getTitlesWidget: (value, _) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF8D7B68),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
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
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _fmtShortMonth(dt),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF8D7B68),
                                      fontWeight: FontWeight.w500,
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
                            isCurved: false, // Straight lines as per image
                            barWidth: 2,
                            color: lineColor,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3.5,
                                  color: lineColor,
                                  strokeColor: cardBg,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                          ),
                        ],
                        // Touch disabled or minimal
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side Strip
          Container(
            width: 45,
            decoration: const BoxDecoration(
              color: stripBg,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 60), // Offset from top
                // 3 Dots indicator
                _dot(),
                const SizedBox(height: 4),
                _dot(),
                const SizedBox(height: 4),
                _dot(),
                const Spacer(),
                // Optional: put refresh here if needed, or invisible implementation
                IconButton(
                   icon: const Icon(Icons.refresh, color: Colors.transparent, size: 20),
                   onPressed: onRefresh,
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Color(0xFFA68A64), // Same as chart line color
        shape: BoxShape.circle,
      ),
    );
  }
}
