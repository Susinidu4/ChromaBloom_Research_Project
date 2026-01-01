import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class StressAnalysisPage extends StatelessWidget {
  const StressAnalysisPage({super.key});

  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color gold = Color(0xFFBD9A6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // header from your project
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
                    // Top row: back + title + image
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
                                color: gold,
                                decoration: TextDecoration.underline,
                                decorationColor: gold,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // right illustration
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

                    // Latest stress card
                    _LatestStressCard(),

                    const SizedBox(height: 22),

                    Text(
                      "Analysis history",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: gold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _HistoryChartCard(),
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

/* ==================== WIDGETS ==================== */

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

class _LatestStressCard extends StatelessWidget {
  _LatestStressCard();

  static const Color gold = Color(0xFFBD9A6B);
  static const Color cardBorder = Color(0xFFBD9A6B);
  static const Color boxFill = Color(0xFFC7AE85);

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

final now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 15, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1.4),
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
              // date pill
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
                    const SizedBox(height: 4),
                    Text(
                      _monthName(now.month),
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      now.day.toString(),
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

              // level blocks
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
                          child: _LevelBox(filled: true, fillColor: boxFill),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(child: _LevelBox(filled: false)),
                        const SizedBox(width: 10),
                        const Expanded(child: _LevelBox(filled: false)),
                        const SizedBox(width: 10),
                        const Expanded(child: _LevelBox(filled: false)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LvlLabel extends StatelessWidget {
  final String t;
  const _LvlLabel(this.t);

  static const Color gold = Color(0xFFBD9A6B);

  @override
  Widget build(BuildContext context) {
    return Text(
      t,
      style: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: gold,
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

class _HistoryChartCard extends StatelessWidget {
  const _HistoryChartCard();

  static const Color gold = Color(0xFFBD9A6B);

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
      child: Column(
        children: [
          Container(
            height: 230,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: CustomPaint(
              painter: _SimpleLineChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple chart painter to match your UI (no external chart package needed)
class _SimpleLineChartPainter extends CustomPainter {
  static const Color line = Color(0xFFBD9A6B);
  static const Color grid = Color(0x33BD9A6B);

  @override
  void paint(Canvas canvas, Size size) {
    final pGrid = Paint()
      ..color = grid
      ..strokeWidth = 1;

    // axes padding
    const leftPad = 38.0;
    const bottomPad = 26.0;
    final w = size.width - leftPad - 10;
    final h = size.height - bottomPad - 10;

    // draw y labels (Low..Critical)
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final labels = ["Low", "Medium", "High", "Critical"];
    for (int i = 0; i < labels.length; i++) {
      final y = 10 + h - (h * i / 3);
      tp.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          fontFamily: "Poppins",
          fontSize: 12,
          color: Color(0xFFB89A76),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(-13, y - 8));
      // grid lines
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + w, y), pGrid);
    }

    // x axis line
    canvas.drawLine(
      Offset(leftPad, 10 + h),
      Offset(leftPad + w, 10 + h),
      pGrid,
    );

    // sample points to match screenshot trend
    final points = <Offset>[
      Offset(leftPad + w * 0.05, 10 + h * 0.92),
      Offset(leftPad + w * 0.22, 10 + h * 0.75),
      Offset(leftPad + w * 0.45, 10 + h * 0.70),
      Offset(leftPad + w * 0.55, 10 + h * 0.40),
      Offset(leftPad + w * 0.72, 10 + h * 0.44),
      Offset(leftPad + w * 0.88, 10 + h * 0.20),
      Offset(leftPad + w * 0.97, 10 + h * 0.05),
    ];

    final pLine = Paint()
      ..color = line
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, pLine);

    // dots
    final pDot = Paint()..color = line;
    for (final pt in points) {
      canvas.drawCircle(pt, 4, pDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
