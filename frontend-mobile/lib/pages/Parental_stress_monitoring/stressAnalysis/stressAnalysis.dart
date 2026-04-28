import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:provider/provider.dart';
import '../../../state/session_provider.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';
import '../../../services/Parental_stress_monitoring/stress_analysis_service.dart';

class StressAnalysisPage extends StatefulWidget {
  const StressAnalysisPage({super.key});

  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color gold = Color(0xFFBD9A6B);

  @override
  State<StressAnalysisPage> createState() => _StressAnalysisPageState();
}

class _StressAnalysisPageState extends State<StressAnalysisPage> {
  // Replace with your logged-in caregiver id
  //final String caregiverId = "p-0001";

  String? caregiverId;

  late Future<StressComputeResponse> _future;

  late Future<StressHistoryResponse> _historyFuture;

  @override
  void initState() {
    super.initState();

    // Delay until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      final id = (session.caregiver?['_id'] ?? session.caregiver?['id'] ?? '')
          .toString();

      if (id.isEmpty) return;

      setState(() {
        caregiverId = id;
        _future = StressAnalysisService.compute(caregiverId: caregiverId!);
        _historyFuture = StressAnalysisService.getHistory(
          caregiverId: caregiverId!,
          limit: 10,
        );
      });
    });
  }

  // Call this to refresh both current stress and history
  void _reload() {
    setState(() {
      _future = StressAnalysisService.compute(caregiverId: caregiverId!);
      _historyFuture = StressAnalysisService.getHistory(
        caregiverId: caregiverId!,
        limit: 10,
      );
    });
  }

  // Convert technical errors into user-friendly messages
  String friendlyErrorMessage(Object? err) {
    final msg = err.toString().toLowerCase();

    if (msg.contains("socketexception") ||
        msg.contains("failed host lookup") ||
        msg.contains("connection")) {
      return "No internet connection.\nPlease check Wi-Fi/mobile data and try again.";
    }

    if (msg.contains("timeout")) {
      return "The server is taking too long.\nPlease try again in a moment.";
    }

    if (msg.contains("401") || msg.contains("unauthorized")) {
      return "Your session expired.\nPlease login again.";
    }

    if (msg.contains("404")) {
      return "Stress analysis not found yet.\nPlease try again later.";
    }

    if (msg.contains("500") || msg.contains("server")) {
      return "Server error occurred.\nPlease try again later.";
    }

    return "Something went wrong.\nPlease try again.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StressAnalysisPage.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
            ),
            // CONTENT AREA (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BackCircleButton(onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              "Your Stress\nAnalysis",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 20,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                color: StressAnalysisPage.gold,
                                decoration: TextDecoration.underline,
                                decorationColor: StressAnalysisPage.gold,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 150,
                          height: 140,
                          child: Image.asset(
                            "assets/stress_analyze.png",
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.psychology_alt,
                              size: 64,
                              color: Color(0xFF58748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Current Stress Analysis
                    FutureBuilder<StressComputeResponse>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const _LoadingCard();
                        }
                        if (snap.hasError) {
                          return _ErrorCard(
                            message: friendlyErrorMessage(snap.error),
                            onRetry: _reload,
                          );
                        }

                        final data = snap.data;

                        if (data == null || data.stress == null) {
                          return _EmptyStressCard();
                        }

                        final stress = data.stress;
                        final rec = data.recommendation;

                        final date =
                            stress.scoreDate ??
                            stress.computedAt ??
                            DateTime.now();

                        // Add recommendation card below stress card if rec != null
                        return Column(
                          children: [
                            _LatestStressCard(
                              stressLevel: stress.stressLevel,
                              date: date,
                              stressScore: stress.stressScore,
                              stressProbability: stress.stressProbability,
                              consecutiveHighDays: stress.consecutiveHighDays,
                              escalationTriggered: stress.escalationTriggered,
                              raw: stress.raw,
                            ),
                            const SizedBox(height: 14),
                            // _RecommendationCard(recommendation: rec),
                          ],
                        );
                      },
                    ),

                    // History Chart
                    const SizedBox(height: 22),
                    Text(
                      "Analysis history",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: StressAnalysisPage.gold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Keep your chart section if you already have it
                    _HistoryChartCard(historyFuture: _historyFuture),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 0),
    );
  }
}

/* ===================== UI WIDGETS ===================== */

class _BackCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackCircleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 234, 232, 229),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFFC6A477),
          ),
        ),
      ),
    );
  }
}

// Simple card to show loading state while fetching stress analysis
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 15, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBD9A6B), width: 1.4),
      ),
      child: const Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              "Loading latest stress…",
              style: TextStyle(fontFamily: "Poppins"),
            ),
          ),
        ],
      ),
    );
  }
}

// Card to show user-friendly error messages with a retry button
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 15, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBD9A6B), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Latest stress level",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBD9A6B),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFBD9A6B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: Color(0xFF8B6B44),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ),
        ],
      ),
    );
  }
}

// Card to show when there's no stress analysis available yet (e.g. new user)
class _EmptyStressCard extends StatelessWidget {
  const _EmptyStressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBD9A6B), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // You can customize this message or design as needed
          Text(
            "Latest stress level",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBD9A6B),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "No stress analysis available yet.\n"
            "Please complete your daily inputs to generate analysis.",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              color: Color(0xFF8B6B44),
            ),
          ),
        ],
      ),
    );
  }
}

// Card to display the latest stress analysis result with details and confidence levels
class _LatestStressCard extends StatelessWidget {
  final String stressLevel;
  final DateTime date;

  final int stressScore; // 0..3
  final double stressProbability;
  final List<double>? raw;
  final int consecutiveHighDays;
  final bool escalationTriggered;

  const _LatestStressCard({
    required this.stressLevel,
    required this.date,
    required this.stressScore,
    required this.stressProbability,
    required this.consecutiveHighDays,
    required this.escalationTriggered,
    this.raw,
  });

  static const Color gold = Color(0xFFBD9A6B);
  static const Color boxFill = Color(0xFFC7AE85);

  bool _isFilled(String label) =>
      label.toLowerCase() == stressLevel.toLowerCase();

  // Helper to convert month number to short name
  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  // Main build method for the stress card
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 15, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Latest stress level",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: gold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 80,
                height: 103,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7DDCF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                // Display date information
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _monthName(date.month),
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        color: gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Right side: Stress level boxes + details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _LvlLabel("Low"),
                        _LvlLabel("Medium"),
                        _LvlLabel("High"),
                        _LvlLabel("Critical"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _LevelBox(
                            filled: _isFilled("Low"),
                            fillColor: boxFill,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LevelBox(
                            filled: _isFilled("Medium"),
                            fillColor: boxFill,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LevelBox(
                            filled: _isFilled("High"),
                            fillColor: boxFill,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LevelBox(
                            filled: _isFilled("Critical"),
                            fillColor: boxFill,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // _MetaRow(label: "Stress score", value: "$stressScore / 3"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Stress Analysis Details
              Expanded(child: _stressDetailsBlock()),

              // Right side: Detected + Confidence (as your screenshot)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Detected   : $stressLevel",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: gold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Confidence : ${(stressProbability * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // _MetaRow(label: "Consecutive high days", value: "$consecutiveHighDays"),
          // _MetaRow(label: "Escalation", value: escalationTriggered ? "Triggered" : "Not triggered"),
        ],
      ),
    );
  }

  // Helper to display the raw confidence levels for each stress category (if available)
  Widget _stressDetailsBlock() {
    if (raw == null || raw!.isEmpty) return const SizedBox.shrink();

    const labels = ["Low", "Medium", "High", "Critical"];
    final count = raw!.length < 4 ? raw!.length : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stress Analysis Details",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: gold,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFFBD9A6B),
            decorationThickness: 2,
          ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    labels[i],
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: gold,
                    ),
                  ),
                ),
                const Text(
                  ":",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: gold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${(raw![i] * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: gold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Reusable widget to display a label-value pair, right-aligned
class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBD9A6B),
            ),
          ),
          const SizedBox(width: 6), // spacing between label & value
          Text(
            value,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBD9A6B),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple widget to display stress level labels above the boxes
class _LvlLabel extends StatelessWidget {
  final String t;
  const _LvlLabel(this.t);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 55,
      child: Text("", textAlign: TextAlign.center),
    ).copyWithText(t);
  }
}

extension _TextReplace on SizedBox {
  Widget copyWithText(String t) {
    return SizedBox(
      width: width,
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: "Poppins",
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFBD9A6B),
        ),
      ),
    );
  }
}

// Widget to display the filled/unfilled boxes for each stress level category
class _LevelBox extends StatelessWidget {
  final bool filled;
  final Color fillColor;

  const _LevelBox({
    required this.filled,
    this.fillColor = const Color(0xFFC7AE85),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: filled ? fillColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBD9A6B), width: 1.3),
      ),
    );
  }
}

// Card to display the recommendation based on the latest stress analysis result
class _RecommendationCard extends StatelessWidget {
  final RecommendationDto? recommendation;
  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9DDCC),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recommendation",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD9A6B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            rec?.title ?? "No recommendation available",
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6E4F2B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rec?.description ??
                "Try adding a matching recommendation for this level in DB.",
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              color: Color(0xFF6E4F2B),
            ),
          ),
          if (rec?.category != null) ...[
            const SizedBox(height: 8),
            Text(
              "Category: ${rec!.category}",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6E4F2B),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Card to display the history chart of stress levels over time using fl_chart package
class _HistoryChartCard extends StatelessWidget {
  final Future<StressHistoryResponse> historyFuture;
  const _HistoryChartCard({required this.historyFuture});

  static const Color gold = Color(0xFFBD9A6B);

  int _levelToY(String level) {
    switch (level.toLowerCase()) {
      case "low":
        return 0;
      case "medium":
        return 1;
      case "high":
        return 2;
      case "critical":
        return 3;
      default:
        return 0;
    }
  }

  // Helper to convert Y values back to stress level labels for the left axis
  String _yToLabel(double v) {
    final i = v.round().clamp(0, 3);
    return const ["Low", "Medium", "High", "Critical"][i];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9DDCC),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          height: 220,
          child: FutureBuilder<StressHistoryResponse>(
            future: historyFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    "Failed to load history\n${snap.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: "Poppins", fontSize: 12),
                  ),
                );
              }

              final items = snap.data?.items ?? [];
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    "No history data yet",
                    style: TextStyle(fontFamily: "Poppins"),
                  ),
                );
              }

              // API returns newest first -> reverse so left is oldest, right is newest
              final ordered = items.reversed.toList();

              final spots = <FlSpot>[];
              for (int i = 0; i < ordered.length; i++) {
                spots.add(
                  FlSpot(
                    i.toDouble(),
                    _levelToY(ordered[i].stressLevel).toDouble(),
                  ),
                );
              }

              return LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 3,
                  gridData: FlGridData(
                    show: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFD8C6B4),
                        strokeWidth: 1,
                      );
                    },
                  ),

                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(
                        color: Color(0xFFBD9A6B),
                        width: 1.5,
                      ), // Y axis
                      bottom: BorderSide(
                        color: Color(0xFFBD9A6B),
                        width: 1.5,
                      ), // X axis
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      barWidth: 2,
                      color: const Color(0xFFBD9A6B),
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],

                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              _yToLabel(value),
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFBD9A6B),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= ordered.length)
                            return const SizedBox.shrink();

                          // reduce clutter
                          if (ordered.length > 6 && i % 2 == 1)
                            return const SizedBox.shrink();

                          final d =
                              ordered[i].scoreDate ?? ordered[i].computedAt;
                          final label = d == null
                              ? "${i + 1}"
                              : "${d.day}/${d.month}";
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B6B44),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
