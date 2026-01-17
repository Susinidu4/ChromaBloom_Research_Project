import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../state/session_provider.dart';

import '../others/header.dart';
import '../others/navBar.dart';

import '../../services/Interactive_visual_task_scheduler_services/system_activity_service.dart';

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

  static const Color cardBg = Color(0xFFF7EAD7);
  static const Color chartFill = Color(0xFFDFC7A7);
  //static const Color chartLine = Color(0xFFB0896E);
  List<String> _dailyDates14 = List.filled(14, "");

  Future<Map<String, dynamic>>? _latestSummaryFuture;

  //final String caregiverId = "p-0001";

  String _getLoggedCaregiverId(BuildContext context) {
    final session = context.read<SessionProvider>();

    final caregiverId =
        (session.caregiver?['_id'] ?? session.caregiver?['id'] ?? '')
            .toString();

    return caregiverId;
  }

  // cycle label shown in the pill (from backend)
  String _selectedCycleLabel = "Select Cycle";
  String? _selectedPlanId; // selectedCycle.planMongoId

  Map<String, dynamic>? _dashboardCache; // last successful dashboard response
  bool _loadingCycle = false; // optional: show loader in pill

  // ✅ chart values (NOT final, because must update)
  List<double> _overallProgress = [];
  int _completedSteps = 0;
  int _skippedSteps = 0;
  List<double> _dailyProgress14 = List.filled(14, 0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final caregiverId = _getLoggedCaregiverId(context);

      if (caregiverId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Caregiver not logged in")),
        );
        return;
      }

      setState(() {
        _latestSummaryFuture = ChildRoutinePlanService.getLatestRoutineSummary(
          caregiverId: caregiverId,
        );
        _loadingCycle = true;
      });

      _loadDashboard(caregiverId: caregiverId);
    });
  }

  double _diffToNumber(String diff) {
    final d = diff.toLowerCase().trim();
    if (d == "easy") return 1;
    if (d == "medium") return 2;
    if (d == "hard") return 3;
    return 0;
  }

  Future<Map<String, dynamic>> _loadDashboard({
    required String caregiverId,
    String? planId,
  }) async {
    try {
      final res = await ChildRoutinePlanService.getRoutineDashboard(
        caregiverId: caregiverId,
        planId: planId,
      );

      if (!mounted) return res;

      _dashboardCache = res;

      setState(() {
        _applyDashboardToState(res);
        _loadingCycle = false;
      });

      return res;
    } catch (e) {
      if (!mounted) rethrow;

      setState(() {
        _loadingCycle = false; // ✅ IMPORTANT: stop loading even on error
      });

      // optional: show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load dashboard. Check server & planId."),
        ),
      );

      rethrow;
    }
  }

  String _cap(String s) {
    final t = s.trim().toLowerCase();
    if (t.isEmpty) return s;
    return t[0].toUpperCase() + t.substring(1);
  }

  Future<void> _pickCycleFromDashboard(
    Map<String, dynamic> dashboardRes,
  ) async {
    final data = (dashboardRes["data"] ?? {}) as Map<String, dynamic>;
    final cycles = (data["cycles"] ?? []) as List;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFE9DDCC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: cycles.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final c = cycles[i] as Map<String, dynamic>;

            final label = (c["label"] ?? "").toString();

            // ✅ IMPORTANT: must be Mongo _id (ObjectId)
            final planMongoId = (c["planMongoId"] ?? c["_id"] ?? "").toString();

            return ListTile(
              title: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8D6E4F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () async {
                Navigator.pop(ctx);

                if (planMongoId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid plan id")),
                  );
                  return;
                }

                setState(() {
                  _loadingCycle = true;
                  _selectedPlanId =
                      planMongoId; // ✅ keep selected plan id updated
                });

                await _loadDashboard(
                  caregiverId: _getLoggedCaregiverId(context),
                  planId: planMongoId,
                );
                // ✅ Mongo _id
              },
            );
          },
        );
      },
    );
  }

  void _applyDashboardToState(Map<String, dynamic> res) {
    final data = (res["data"] ?? {}) as Map<String, dynamic>;

    // ✅ Selected cycle label + plan id
    final selected = (data["selectedCycle"] ?? {}) as Map<String, dynamic>;
    final cycleStart = (selected["cycleStart"] ?? "")
        .toString()
        .split("T")
        .first;
    final cycleEnd = (selected["cycleEnd"] ?? "").toString().split("T").first;

    _selectedPlanId = (selected["planMongoId"] ?? "").toString();
    _selectedCycleLabel = "$cycleStart - $cycleEnd";

    // ✅ Overall Progress (difficulty -> 1/2/3)
    final overall = (data["overallProgress"] ?? []) as List;
    _overallProgress = overall.map<double>((e) {
      final diff = (e["difficulty"] ?? "").toString();
      return _diffToNumber(diff);
    }).toList();

    // ✅ Step analysis (pie chart)
    final step = (data["stepAnalysis"] ?? {}) as Map<String, dynamic>;
    _completedSteps = (step["completedStepsTotal"] as num?)?.toInt() ?? 0;
    _skippedSteps = (step["skippedStepsTotal"] as num?)?.toInt() ?? 0;

    // ✅ Daily progress (bar chart) => completionPercent 0..100
    final daily = (data["dailyProgress"] ?? []) as List;

    _dailyProgress14 = List.generate(14, (i) {
      if (i >= daily.length) return 0.0;
      return ((daily[i]["completionPercent"] as num?) ?? 0).toDouble();
    });

    // percent values
    _dailyProgress14 = List.generate(14, (i) {
      if (i >= daily.length) return 0.0;
      return ((daily[i]["completionPercent"] as num?) ?? 0).toDouble();
    });

    // ✅ dates (YYYY-MM-DD)
    _dailyDates14 = List.generate(14, (i) {
      if (i >= daily.length) return "";
      return (daily[i]["date"] ?? "").toString(); // already "YYYY-MM-DD"
    });
  }

  @override
  Widget build(BuildContext context) {
    final int visibleCount = 14;
    final double pointSpacing = 40;
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
                child: (_latestSummaryFuture == null)
                    ? const SizedBox(
                        height: 170,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : FutureBuilder<Map<String, dynamic>>(
                        future: _latestSummaryFuture!,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 170,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (snap.hasError) {
                            return _LatestSummaryCard(
                              previous: "N/A",
                              current: "N/A",
                              message: "Failed to load summary.",
                            );
                          }

                          final body = snap.data ?? {};
                          final data =
                              (body["data"] ?? {}) as Map<String, dynamic>;

                          final prevRaw = data["previousDifficulty"];
                          final currRaw = data["currentDifficulty"];
                          final msgRaw = data["message"];

                          // ✅ fallback for first-time user
                          final previous =
                              (prevRaw == null ||
                                  prevRaw.toString().trim().isEmpty)
                              ? "New"
                              : _cap(prevRaw.toString());

                          final current =
                              (currRaw == null ||
                                  currRaw.toString().trim().isEmpty)
                              ? "N/A"
                              : _cap(currRaw.toString());

                          final message =
                              (msgRaw == null ||
                                  msgRaw.toString().trim().isEmpty)
                              ? "No summary available."
                              : msgRaw.toString();

                          return _LatestSummaryCard(
                            previous: previous,
                            current: current,
                            message: message,
                          );
                        },
                      ),
              ),

              const SizedBox(height: 18),

              // Quote + illustration
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: QuoteSection(
                  quote:
                      "Smart routines that adapt, support, and grow with your child.",
                  imagePath:
                      "assets/InteractiveVisualTaskScheduler/routine_home_Quote.png",
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                    child: SizedBox(
                      height: 220,
                      child: (_overallProgress.length <= visibleCount)
                          ? _OverallLineChart(values: _overallProgress)
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: _overallProgress.length * pointSpacing,
                                child: _OverallLineChart(
                                  values: _overallProgress,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 14 Day Plan Summary (pie)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const _SectionTitle("14 Day Plan Summary"),
                    const Spacer(),
                    _DatePill(
                      text: _loadingCycle ? "Loading..." : _selectedCycleLabel,
                      onTap: () async {
                        final caregiverId = _getLoggedCaregiverId(context);
                        if (caregiverId.isEmpty) return;

                        final cache = _dashboardCache;

                        if (cache == null) {
                          setState(() => _loadingCycle = true);

                          final fresh = await _loadDashboard(
                            caregiverId: caregiverId,
                            planId: null,
                          );

                          if (!mounted) return;
                          await _pickCycleFromDashboard(fresh);
                          return;
                        }

                        await _pickCycleFromDashboard(cache);
                      },
                    ),
                  ],
                ),
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
                          children: const [
                            Text(
                              "Step analysis",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: textBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // 👈 IMPORTANT
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
                              Column(
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
                            ],
                          ),
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
                          children: const [
                            Text(
                              "Progress",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: textBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 190,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: (_dailyProgress14.length * 42)
                                  .toDouble(), // 👈 spacing per day
                              child: _ProgressBarChart(
                                values: _dailyProgress14,
                                dates: _dailyDates14,
                              ),
                            ),
                          ),
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

  const QuoteSection({super.key, required this.quote, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
            height: 200,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),

          const SizedBox(width: 8),

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
          color: const Color(0xFFF3E8E8),
          border: Border.all(color: const Color(0xFFBD9A6B)),
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
                color: Color(0xFFBD9A6B),
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

// All chart Card containers
class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9DDCC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBD9A6B)),
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

// Overall Progress Line Chart
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
        maxY: 4,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFDFC7A7), // 👈 grid color
            strokeWidth: 1,
            dashArray: [6, 4], // optional: dashed look
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: const Color(0xFFDFC7A7),
            strokeWidth: 1,
            dashArray: [6, 4],
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: const Color(0xFFDFC7A7), // 👈 your theme color
            width: 1.8,
          ),
        ),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 4),
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
              padding: EdgeInsets.only(right: 2),
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
              reservedSize: 45,
              getTitlesWidget: (v, meta) {
                const style = TextStyle(color: Color(0xFFBD9A6B), fontSize: 10);

                bool isClose(double a, double b) => (a - b).abs() < 0.001;

                if (isClose(v, 1)) return const Text("Easy", style: style);
                if (isClose(v, 2)) return const Text("Medium", style: style);
                if (isClose(v, 3)) return const Text("Hard", style: style);

                return const SizedBox.shrink(); // hide everything else (including the bottom)
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2,
            color: const Color(0xFFB0896E),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFDFC7A7).withOpacity(0.64),
            ),
          ),
        ],
      ),
    );
  }
}

// Steps analysis Pie Chart
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
            color: const Color(0xFFDFC7A7),
            borderSide: const BorderSide(color: Color(0xFFBD9A6B), width: 2),
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
            color: const Color(0xFFF7EAD7),
            borderSide: const BorderSide(color: Color(0xFFBD9A6B), width: 2),
          ),
        ],
      ),
    );
  }
}

// pie chart legend row
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
            color: Color(0xFFBD9A6B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// Progress Bar Chart
class _ProgressBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> dates;

  const _ProgressBarChart({
    required this.values,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < values.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i, // 👈 use index as x (0..13)
          barRods: [
            BarChartRodData(
              toY: values[i],
              width: 16,
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFFBD9A6B),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween, // 👈 nice spacing
        maxY: 100,

        gridData: FlGridData(
          show: true,
          horizontalInterval: 20,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFDFC7A7),
            strokeWidth: 1,
            dashArray: [6, 4],
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: const Color(0xFFDFC7A7),
            width: 1.8,
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
              reservedSize: 34,
              getTitlesWidget: (v, meta) {
                final i = v.toInt(); // 0..13
                if (i < 0 || i >= dates.length) return const SizedBox.shrink();

                final d = dates[i]; // "YYYY-MM-DD"
                if (d.isEmpty) return const SizedBox.shrink();

                final parts = d.split("-");
                final label =
                    (parts.length == 3) ? "${parts[2]}/${parts[1]}" : d;

                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF8D6E4F),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
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

