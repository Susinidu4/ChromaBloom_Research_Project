import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../others/header.dart';
import '../others/navBar.dart';

class RoutineHomeScreen extends StatefulWidget {
  const RoutineHomeScreen({super.key});

  @override
  State<RoutineHomeScreen> createState() => _RoutineHomeScreenState();
}

class _RoutineHomeScreenState extends State<RoutineHomeScreen> {
  // ---------- Colors (picked to match your UI) ----------
  static const Color pageBg = Color(0xFFF3E8E8);

  static const Color cardBorder = Color(0xFFD8C6B4);

  //static const Color accentBrown = Color(0xFFB0896E);
  static const Color textBrown = Color(0xFFBD9A6B);

  static const Color cardBg = Color(0xFFF8F2E8);
  static const Color chartFill = Color(0xFFD8C6B4);
  //static const Color chartLine = Color(0xFFB0896E);

  // Dummy chart data (replace with your real API values)
  final List<double> _overallProgress = [
    2.2,
    1.8,
    2.5,
    2.0,
    1.1,
    1.9,
    1.2,
    2.7,
    2.6,
    1.3,
  ];
  final int _completedSteps = 25;
  final int _skippedSteps = 10;

  final List<double> _dailyProgress14 = [
    35,
    75,
    45,
    65,
    5,
    3,
    2,
    65,
    6,
    5,
    50,
    48,
    60,
    35,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MainHeader(
                title: "Hello!",
                subtitle: "Welcome back",
                notificationCount: 0,
              ),
              const SizedBox(height: 14),

              // Routine Plan button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _PillButton(
                    text: "Routine Plan",
                    onTap: () {
                      Navigator.pushNamed(context, "/displayUserActivity");
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Latest Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _SectionTitle("Latest Summary"),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _LatestSummaryCard(
                  previous: "Easy",
                  current: "Medium",
                  message:
                      "Wonderful progress! The child is ready for the next level with new Medium-difficulty activities.",
                ),
              ),

              const SizedBox(height: 18),

              // Quote + illustration
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: QuoteSection(
                  quote:
                      "Smart routines that adapt, support, and grow with your child.",
                  imagePath: "assets/InteractiveVisualTaskScheduler/routine_home_Quote.png",
                ),
              ),

              const SizedBox(height: 18),

              // Overall Progress line chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _SectionTitle("Overall Progress"),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _ChartCard(
                  child: SizedBox(
                    height: 170,
                    child: _OverallLineChart(values: _overallProgress),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 14 Day Plan Summary (pie)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _SectionTitle("14 Day Plan Summary"),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _ChartCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Step analysis",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: textBrown,
                              ),
                            ),
                            const Spacer(),
                            _DatePill(
                              text: "2/11/2025 - 15/11/2025",
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: _StepsPieChart(
                                completed: _completedSteps,
                                skipped: _skippedSteps,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _LegendRow(
                                    color: chartFill,
                                    text: "Completed Steps",
                                  ),
                                  const SizedBox(height: 10),
                                  _LegendRow(
                                    color: cardBg,
                                    borderColor: cardBorder,
                                    text: "Skipped Steps",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Progress bar chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _ChartCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Progress",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: textBrown,
                              ),
                            ),
                            const Spacer(),
                            _DatePill(
                              text: "2/11/2025 - 15/11/2025",
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 170,
                          child: _ProgressBarChart(values: _dailyProgress14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 1),
    );
  }
}

// Routine Plan button
class _PillButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PillButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EAD7),
          border: Border.all(color: const Color(0xFFD8C6B4), width: 1.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFBD9A6B),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Color(0xFFBD9A6B),
            ),
          ],
        ),
      ),
    );
  }
}

// Tittle for sections
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFBD9A6B),
        fontSize: 16,
        fontWeight: FontWeight.w900,
        decoration: TextDecoration.underline,
        decorationColor: Color(0xFFBD9A6B),
        decorationThickness: 1.5,
      ),
    );
  }
}

// Latest Summary Card
class _LatestSummaryCard extends StatelessWidget {
  final String previous;
  final String current;
  final String message;

  const _LatestSummaryCard({
    required this.previous,
    required this.current,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8C6B4), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, card) {
          // ✅ Right-side image column width (responsive)
          final double imgColW = (card.maxWidth * 0.42).clamp(150.0, 220.0);

          // ✅ Image height inside that column (responsive + elegant)
          final double imgH = (imgColW * 0.85).clamp(130.0, 190.0);

          return Stack(
            clipBehavior:
                Clip.none, // ✅ allow image to overflow without resizing card
            children: [
              // ✅ This Row decides the card height (based on TEXT only)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT TEXT AREA (UNCHANGED)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kvLine("Previous Difficulty Level :", previous),
                        const SizedBox(height: 16),
                        _kvLine("Current Difficulty Level  :", current),
                        const SizedBox(height: 26),
                        const Text(
                          "Message :",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFBD9A6B),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.5,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFFBD9A6B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ✅ Reserve right space so text doesn't go under image
                  SizedBox(width: imgColW),
                ],
              ),

              // ✅ Image overlay (can be BIGGER, but doesn't change card height)
              Positioned(
                right: 0,
                top: -50, // adjust up/down
                child: SizedBox(
                  width: imgColW,
                  height: 240, // ✅ increase image size here
                  child: Image.asset(
                    "assets/InteractiveVisualTaskScheduler/routine_home_summary.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _kvLine(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFFBD9A6B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ),
      ],
    );
  }
}

// Quote Section
class QuoteSection extends StatelessWidget {
  final String quote;
  final String imagePath;

  const QuoteSection({
    super.key,
    required this.quote,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF7EAD7), // warm left
            const Color(0xFFF3E8E8).withOpacity(0.85), // merge with bg right
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT IMAGE (big like UI)
          SizedBox(
            height: 150,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 28),

          // RIGHT QUOTE TEXT
          Expanded(
            child: Text(
              '“ $quote ”',
              style: const TextStyle(
                color: Color(0xFFBD9A6B),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _DatePill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _DatePill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE9DDCC),
          border: Border.all(color: const Color(0xFFD8C6B4)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF8D6E4F),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.calendar_month_rounded,
              size: 16,
              color: Color(0xFF8D6E4F),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8C6B4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String text;

  const _LegendRow({required this.color, required this.text, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1.4)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF8D6E4F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ==========================
// Charts
// ==========================
class _OverallLineChart extends StatelessWidget {
  final List<double> values;
  const _OverallLineChart({required this.values});

  @override
  Widget build(BuildContext context) {
    // y: 1=Easy, 2=Medium, 3=Hard (like your axis labels)
    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return LineChart(
      LineChartData(
        minY: 0.5,
        maxY: 3.2,
        gridData: FlGridData(show: true, drawVerticalLine: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                "Plan no",
                style: TextStyle(
                  color: Color(0xFF8D6E4F),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(color: Color(0xFF8D6E4F), fontSize: 10),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Text(
                "Complexity",
                style: TextStyle(
                  color: Color(0xFF8D6E4F),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 44,
              getTitlesWidget: (v, meta) {
                String label = "";
                if (v.round() == 1) label = "Easy";
                if (v.round() == 2) label = "Medium";
                if (v.round() == 3) label = "Hard";
                return Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8D6E4F),
                    fontSize: 10,
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
            barWidth: 3,
            color: const Color(0xFFB0896E),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFD8C6B4).withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsPieChart extends StatelessWidget {
  final int completed;
  final int skipped;

  const _StepsPieChart({required this.completed, required this.skipped});

  @override
  Widget build(BuildContext context) {
    final total = (completed + skipped).clamp(1, 999999);
    final completedPct = completed / total;
    final skippedPct = skipped / total;

    return PieChart(
      PieChartData(
        centerSpaceRadius: 0,
        sectionsSpace: 2,
        sections: [
          PieChartSectionData(
            value: completedPct * 100,
            title: completed.toString(),
            radius: 70,
            titleStyle: const TextStyle(
              color: Color(0xFF8D6E4F),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
            color: const Color(0xFFD8C6B4),
          ),
          PieChartSectionData(
            value: skippedPct * 100,
            title: skipped.toString(),
            radius: 70,
            titleStyle: const TextStyle(
              color: Color(0xFF8D6E4F),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
            color: const Color(0xFFF8F2E8),
            borderSide: const BorderSide(color: Color(0xFFD8C6B4), width: 2),
          ),
        ],
      ),
    );
  }
}

class _ProgressBarChart extends StatelessWidget {
  final List<double> values;
  const _ProgressBarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < values.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i + 1,
          barRods: [
            BarChartRodData(
              toY: values[i],
              width: 10,
              borderRadius: BorderRadius.circular(3),
              color: const Color(0xFFB0896E),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        maxY: 90,
        gridData: FlGridData(show: true, horizontalInterval: 20),
        borderData: FlBorderData(show: true),
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
              interval: 20,
              reservedSize: 32,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(color: Color(0xFF8D6E4F), fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final n = v.toInt();
                if (n < 1 || n > values.length) return const SizedBox.shrink();
                return Text(
                  n.toString(),
                  style: const TextStyle(
                    color: Color(0xFF8D6E4F),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: groups,
      ),
    );
  }
}
