import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class DrawingLessonDetailPage extends StatelessWidget {
  const DrawingLessonDetailPage({super.key});

  static const Color pageBg = Color(0xFFF5ECEC);

  // UI palette (same family as your other pages)
  static const Color topRowBlue = Color(0xFF3D6B86);

  static const Color bubbleBg = Color(0xFFF8F2E8);
  static const Color bubbleIcon = Color(0xFFB0896E);

  static const Color tipCardBg = Color(0xFFE9DDCC);
  static const Color titleColor = Color(0xFFA07E6A);
  static const Color bodyColor = Color(0xFFB79B86);

  static const Color videoBoxBg = Color(0xFFE0E0E0);
  static const Color videoBorder = Color(0xFFD8C6B4);

  static const Color buttonBg = Color(0xFFB89A76);

  @override
  Widget build(BuildContext context) {
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
                    // ===== Back + centered unit title =====
                    Row(
                      children: [
                        _BackCircleButton(onTap: () => Navigator.pop(context)),
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
                        const SizedBox(width: 40), // balance right side
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ===== Lesson title =====
                    const Text(
                      "How to draw a Circle",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ===== Video placeholder =====
                    _VideoBox(
                      onTap: () {
                        // TODO: play video / open player
                      },
                    ),

                    const SizedBox(height: 14),

                    // ===== Tip card =====
                    _TipCard(
                      tipText:
                          "1. Trace an Object - Use a cup or lid and trace around it to make an easy circle.\n\n"
                          "2. Finger Circle in Sand - Let the child draw a circle using their finger in sand/soil to slowly learn making circles.\n\n"
                          "3. Sticker Shape - Place round stickers in a loop to form a circle shape.\n\n"
                          "4. Spin & Trace - Spin a round object (like a lid) and trace around it once it stops.\n\n"
                          "5. Circle Movement - Draw a big circle in the air with your arm, then draw the same on paper.",
                      onContinue: () {
                        // TODO: go next
                        // Navigator.pushNamed(context, '/nextLesson');
                      },
                    ),
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

/* ===================== BACK BUTTON ===================== */

class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: DrawingLessonDetailPage.bubbleBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 26,
            color: DrawingLessonDetailPage.bubbleIcon,
          ),
        ),
      ),
    );
  }
}

/* ===================== VIDEO BOX ===================== */

class _VideoBox extends StatelessWidget {
  const _VideoBox({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(2),
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: DrawingLessonDetailPage.videoBoxBg,
              border: Border.all(color: DrawingLessonDetailPage.videoBorder),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                size: 56,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== TIP CARD ===================== */

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tipText,
    required this.onContinue,
  });

  final String tipText;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: DrawingLessonDetailPage.tipCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tip title
          const Text(
            "Tip",
            style: TextStyle(
              color: DrawingLessonDetailPage.titleColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          // Illustration
          Center(
            child: Image.asset(
              "assets/tip_illustration.png", 
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Tip illustration missing",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Tip text
          Text(
            tipText,
            style: const TextStyle(
              color: DrawingLessonDetailPage.bodyColor,
              fontSize: 9.6,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          // Continue button (center)
          Center(
            child: _PrimaryButton(
              label: "Continue",
              onTap: onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== BUTTON ===================== */

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: DrawingLessonDetailPage.buttonBg,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
