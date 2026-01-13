import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class ProblemSolvingLessonCompletePage extends StatelessWidget {
  const ProblemSolvingLessonCompletePage({super.key});

  static const Color pageBg = Color(0xFFF5ECEC);

  // Top row colors
  static const Color topRowBlue = Color(0xFF3D6B86);
  static const Color circleBg = Color(0xFFF8F2E8);
  static const Color circleBorder = Color(0xFFD8C6B4);
  static const Color circleIcon = Color(0xFFB0896E);

  // Progress colors (match your UI)
  static const Color track = Color(0xFFD8D1C7);
  static const Color fill = Color(0xFFB89A76);

  static const Color labelColor = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    // Example values (0.0 - 1.0)
    final improvement = 0.62;
    final correctness = 0.84;

    return Scaffold(
      backgroundColor: pageBg,
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
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Top row: icon + title + close =====
                    Row(
                      children: [
                        Image.asset(
                          "assets/problem-solving.png",
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.psychology_alt_rounded,
                            size: 24,
                            color: topRowBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Problem Solving UNIT 1",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: topRowBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _CircleActionButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Lesson Complete",
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===== Illustration =====
                    Center(
                      child: Image.asset(
                        "assets/win2.png", 
                        height: 235,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 235,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            "Illustration Missing",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===== Improvement =====
                    const Text(
                      "Improvement",
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ThickProgressBar(value: improvement),

                    const SizedBox(height: 14),

                    // ===== Correctness =====
                    const Text(
                      "Correctness",
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ThickProgressBar(value: correctness),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 2),
    );
  }
}

/* ===================== TOP RIGHT CIRCLE BUTTON ===================== */

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: ProblemSolvingLessonCompletePage.circleBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: ProblemSolvingLessonCompletePage.circleBorder,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: ProblemSolvingLessonCompletePage.circleIcon,
          ),
        ),
      ),
    );
  }
}

/* ===================== PROGRESS BAR (THICK) ===================== */

class _ThickProgressBar extends StatelessWidget {
  const _ThickProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      height: 14, // ✅ thicker like your UI
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Container(color: ProblemSolvingLessonCompletePage.track),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(color: ProblemSolvingLessonCompletePage.fill),
            ),
          ],
        ),
      ),
    );
  }
}
