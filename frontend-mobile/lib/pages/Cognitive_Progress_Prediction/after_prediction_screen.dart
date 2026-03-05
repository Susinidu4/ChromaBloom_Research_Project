import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AfterPredictionScreen extends StatefulWidget {
  const AfterPredictionScreen({super.key});

  @override
  State<AfterPredictionScreen> createState() => _AfterPredictionScreenState();
}

class _AfterPredictionScreenState extends State<AfterPredictionScreen> {
  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF7ECE1);
    const cardColor = Color(0xFFEBE0D0);
    const titleColor = Color(0xFF8D7B68);
    const textColor = Color(0xFF8D7B68);
    const axisColor = Color(0xFFBCA686);
    const lineColor = Color(0xFFA68A64);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFFAC9375),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Main Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          "Cognitive Progress Prediction",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Chart
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 3,
                                    reservedSize: 25,
                                    getTitlesWidget: (value, _) => Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: axisColor,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, _) {
                                      const labels = ["Apr", "Feb", "Apr", "Apr", "Apr", "Apr", "Apr"];
                                      final i = value.toInt();
                                      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          labels[i],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: axisColor,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  left: BorderSide(color: axisColor, width: 1.5),
                                  bottom: BorderSide(color: axisColor, width: 1.5),
                                ),
                              ),
                              minX: 0,
                              maxX: 6,
                              minY: 0,
                              maxY: 10,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    const FlSpot(0, 1),
                                    const FlSpot(1, 2.5),
                                    const FlSpot(2, 3),
                                    const FlSpot(3, 5.5),
                                    const FlSpot(4, 5),
                                    const FlSpot(5, 7.5),
                                    const FlSpot(6, 10),
                                  ],
                                  isCurved: false,
                                  color: lineColor,
                                  barWidth: 2,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Analysis Text
                        Text(
                          "The chart shows a clear upward improvement trend over the next 14 days. Values gradually rise from low levels at the beginning, with a small dip in the middle, but then continue climbing steadily toward the highest point at the end. Overall, the data indicates consistent progress and positive improvement.",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withOpacity(0.8),
                            height: 1.5,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Bottom Section (Boy + Trend List)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Boy Illustration
                            Expanded(
                              flex: 2,
                              child: Image.asset(
                                'assets/images/boy.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Trend Description List
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Trend Description",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: titleColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _bulletPoint("The values show a steady upward trend."),
                                  _bulletPoint("One slight dip between point 4 - 5 (7 down to 6)."),
                                  _bulletPoint("Final rise from 6 - 8 - 10 indicates strong improvement."),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Color(0xFFC49F7D), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8D7B68),
                height: 1.4,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}