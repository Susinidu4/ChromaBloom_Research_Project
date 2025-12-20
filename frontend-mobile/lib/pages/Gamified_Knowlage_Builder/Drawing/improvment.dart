import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class LessonCompletePage extends StatelessWidget {
  const LessonCompletePage({super.key});

  static const Color pageBg = Color(0xFFF5ECEC);

  static const Color topRowBlue = Color(0xFF3D6B86);
  static const Color bubbleBg = Color(0xFFF8F2E8);
  static const Color bubbleIcon = Color(0xFFB0896E);

  static const Color labelColor = Color(0xFF000000);
  static const Color track = Color(0xFFD8D1C7);
  static const Color fill = Color(0xFFB89A76);

  @override
  Widget build(BuildContext context) {
    // example values (0.0 - 1.0)
    final improvement = 0.65;
    final correctness = 0.78;

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
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/drawing_palette.png",
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.palette_rounded,
                            size: 22,
                            color: topRowBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Drawing UNIT 1 Lesson 1",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: topRowBlue,
                              fontSize: 12.5,
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

                    const SizedBox(height: 16),

                    const Text(
                      "Lesson Complete",
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Image.asset(
                      "assets/win.png",
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
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

                    const SizedBox(height: 18),

                    // Improvement
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Improvement",
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ProgressBar(value: improvement),

                    const SizedBox(height: 14),

                    // Correctness
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Correctness",
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ProgressBar(value: correctness),
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
            color: LessonCompletePage.bubbleBg,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD8C6B4), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: LessonCompletePage.bubbleIcon),
        ),
      ),
    );
  }
}

/* ===================== THICK PROGRESS BAR ===================== */

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      height: 18, // ✅ THICKER BAR
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Container(color: LessonCompletePage.track),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(color: LessonCompletePage.fill),
            ),
          ],
        ),
      ),
    );
  }
}
