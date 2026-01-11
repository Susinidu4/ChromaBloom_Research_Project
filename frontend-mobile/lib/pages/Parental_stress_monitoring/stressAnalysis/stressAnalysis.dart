import 'package:flutter/material.dart';

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
  final String caregiverId = "p-0001";

  late Future<StressComputeResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = StressAnalysisService.compute(caregiverId: caregiverId);
  }

  void _reload() {
    setState(() {
      _future = StressAnalysisService.compute(caregiverId: caregiverId);
    });
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
              notificationCount: 5,
            ),
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

                    FutureBuilder<StressComputeResponse>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const _LoadingCard();
                        }
                        if (snap.hasError) {
                          return _ErrorCard(
                            message: snap.error.toString(),
                            onRetry: _reload,
                          );
                        }

                        final data = snap.data!;
                        final stress = data.stress;
                        final rec = data.recommendation;

                        final date = stress.scoreDate ?? stress.computedAt ?? DateTime.now();

                        return Column(
                          children: [
                            _LatestStressCard(
                              stressLevel: stress.stressLevel,
                              date: date,
                              stressScore: stress.stressScore,
                              stressProbability: stress.stressProbability,
                              consecutiveHighDays: stress.consecutiveHighDays,
                              escalationTriggered: stress.escalationTriggered,
                            ),
                            const SizedBox(height: 14),
                            // _RecommendationCard(recommendation: rec),
                          ],
                        );
                      },
                    ),

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
                    const _HistoryChartCard(),
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
          Text(
            message,
            style: const TextStyle(fontFamily: "Poppins", fontSize: 12),
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

class _LatestStressCard extends StatelessWidget {
  final String stressLevel;
  final DateTime date;

  final int stressScore; // 0..3
  final double stressProbability;
  final int consecutiveHighDays;
  final bool escalationTriggered;

  const _LatestStressCard({
    required this.stressLevel,
    required this.date,
    required this.stressScore,
    required this.stressProbability,
    required this.consecutiveHighDays,
    required this.escalationTriggered,
  });

  static const Color gold = Color(0xFFBD9A6B);
  static const Color boxFill = Color(0xFFC7AE85);

  bool _isFilled(String label) => label.toLowerCase() == stressLevel.toLowerCase();

  String _monthName(int month) {
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return months[month - 1];
  }

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
                        Expanded(child: _LevelBox(filled: _isFilled("Low"), fillColor: boxFill)),
                        const SizedBox(width: 10),
                        Expanded(child: _LevelBox(filled: _isFilled("Medium"), fillColor: boxFill)),
                        const SizedBox(width: 10),
                        Expanded(child: _LevelBox(filled: _isFilled("High"), fillColor: boxFill)),
                        const SizedBox(width: 10),
                        Expanded(child: _LevelBox(filled: _isFilled("Critical"), fillColor: boxFill)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Detected: $stressLevel",
                      textAlign: TextAlign.right,
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
          ),
          const SizedBox(height: 10),
          _MetaRow(label: "Stress score", value: "$stressScore / 3"),
          _MetaRow(label: "Probability", value: "${(stressProbability * 100).toStringAsFixed(1)}%"),
          // _MetaRow(label: "Consecutive high days", value: "$consecutiveHighDays"),
          // _MetaRow(label: "Escalation", value: escalationTriggered ? "Triggered" : "Not triggered"),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              color: Color(0xFF8B6B44),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B6B44),
            ),
          ),
        ],
      ),
    );
  }
}

class _LvlLabel extends StatelessWidget {
  final String t;
  const _LvlLabel(this.t);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 55,
      child: Text(
        "",
        textAlign: TextAlign.center,
      ),
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
            rec?.description ?? "Try adding a matching recommendation for this level in DB.",
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

class _HistoryChartCard extends StatelessWidget {
  const _HistoryChartCard();

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
      child: const SizedBox(
        height: 230,
        child: Center(
          child: Text(
            "History chart placeholder",
            style: TextStyle(fontFamily: "Poppins"),
          ),
        ),
      ),
    );
  }
}
