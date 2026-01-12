import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class ProblemSolvingMiniTutorialPage extends StatelessWidget {
  const ProblemSolvingMiniTutorialPage({super.key});

  static const Color pageBg = Color(0xFFF5ECEC);

  // Top row
  static const Color topRowBlue = Color(0xFF3D6B86);
  static const Color circleBg = Color(0xFFF8F2E8);
  static const Color circleBorder = Color(0xFFD8C6B4);
  static const Color circleIcon = Color(0xFFB0896E);

  // Card colors
  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color miniBoxBg = Color(0xFFF8F2E8);
  static const Color miniBoxBorder = Color(0xFFD8C6B4);

  static const Color titleBrown = Color(0xFFA07E6A);
  static const Color bodyBrown = Color(0xFFB79B86);

  // Button
  static const Color btnBg = Color(0xFFB89A76);

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
                  children: [
                    // ===== Top row: icon + title + close =====
                    Row(
                      children: [
                        Image.asset(
                          "assets/problem_solving.png", // change if needed
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

                    const SizedBox(height: 12),

                    // ===== Main big card =====
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2A000000),
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Column(
                          children: [
                            // ===== First section: image + mini tutorial box =====
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // left illustration
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Image.asset(
                                      "assets/ps_mini_1.png", // your top illustration
                                      height: 120,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.black.withOpacity(0.06),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "Image Missing",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // right mini tutorial box
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 10, 12, 10),
                                    decoration: BoxDecoration(
                                      color: miniBoxBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: miniBoxBorder,
                                        width: 1.1,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x12000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Mini Tutorial :",
                                          style: TextStyle(
                                            color: titleBrown,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        _MiniBullet(
                                          "Show two sets of items\n(e.g., spoon–fork, sock–shoe, apple–banana).",
                                        ),
                                        _MiniBullet(
                                          "Ask: “Which two go together?”",
                                        ),
                                        _MiniBullet(
                                          "Let the child choose by\npointing or dragging.",
                                        ),
                                        _MiniBullet(
                                          "Praise correct matches\nwith: “Great matching!”",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // ===== Second section box (Or:) =====
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: miniBoxBg.withOpacity(0.28),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Or:",
                                    style: TextStyle(
                                      color: titleBrown,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "This game should be played together with your\nchild.\n"
                                    "Please stay with your child and guide them while\n"
                                    "they play.\n"
                                    "Your help improves learning and keeps them safe.",
                                    style: TextStyle(
                                      color: bodyBrown,
                                      fontSize: 9.8,
                                      height: 1.25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  _OrBullet("Sit beside your child while playing"),
                                  _OrBullet("Help them understand the task"),
                                  _OrBullet("Do not rush them"),
                                  _OrBullet("Encourage gently, do not correct harshly"),
                                  _OrBullet("Celebrate the child’s effort, not accuracy"),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // bottom illustration
                            Image.asset(
                              "assets/ps_mini_2.png", // your bottom illustration
                              height: 110,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                height: 110,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  "Image Missing",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Continue button (small, centered)
                            Center(
                              child: _PrimaryButton(
                                label: "Continue",
                                onTap: () {
                                  // TODO: go to lesson list / first game
                                  // Navigator.pushNamed(context, '/problemSolvingUnit1');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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
            color: ProblemSolvingMiniTutorialPage.circleBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: ProblemSolvingMiniTutorialPage.circleBorder,
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
            color: ProblemSolvingMiniTutorialPage.circleIcon,
          ),
        ),
      ),
    );
  }
}

/* ===================== BULLETS ===================== */

class _MiniBullet extends StatelessWidget {
  const _MiniBullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              color: ProblemSolvingMiniTutorialPage.titleBrown,
              fontSize: 10.5,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ProblemSolvingMiniTutorialPage.titleBrown,
                fontSize: 9.4,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrBullet extends StatelessWidget {
  const _OrBullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              color: ProblemSolvingMiniTutorialPage.bodyBrown,
              fontSize: 10.5,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ProblemSolvingMiniTutorialPage.bodyBrown,
                fontSize: 9.8,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== CONTINUE BUTTON ===================== */

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
          width: 92, // matches your UI small button
          decoration: BoxDecoration(
            color: ProblemSolvingMiniTutorialPage.btnBg,
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
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
