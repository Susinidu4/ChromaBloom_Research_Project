import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';
import '../../../services/Gemified/problem_solving_lesson_service.dart';

class ProblemSolvingMiniTutorialPage extends StatefulWidget {
  final String lessonId;

  const ProblemSolvingMiniTutorialPage({
    super.key,
    required this.lessonId,
  });

  @override
  State<ProblemSolvingMiniTutorialPage> createState() =>
      _ProblemSolvingMiniTutorialPageState();
}

class _ProblemSolvingMiniTutorialPageState
    extends State<ProblemSolvingMiniTutorialPage> {
  // Background
  static const Color pageBg = Color(0xFFF5ECEC);

  // Top row
  static const Color topRowBlue = Color(0xFF3D6B86);
  static const Color circleBg = Color(0xFFF8F2E8);
  static const Color circleBorder = Color(0xFFD8C6B4);
  static const Color circleIcon = Color(0xFFB0896E);

  // Big card
  static const Color cardBg = Color(0xFFE9DDCC);

  // Inner boxes
  static const Color innerBoxBg = Color(0xFFF7F3ED);
  static const Color innerBoxBorder = Color(0xFFD8C6B4);

  // Text
  static const Color titleBrown = Color(0xFFA07E6A);
  static const Color bodyBlack = Color(0xFF111111);

  // Button
  static const Color btnBg = Color(0xFFB89A76);

  bool loading = true;
  String? error;

  String miniTutorialName = "Mini Tutorial :";
  List<Map<String, dynamic>> tips = [];

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await ProblemSolvingLessonService.getLessonById(widget.lessonId);

      // backend returns { success: true, data: {...} }
      final data = (res["data"] as Map<String, dynamic>?);

      if (data == null) {
        throw Exception("Lesson data not found");
      }

      final name = (data["miniTutorialsName"] ?? "Mini Tutorial :").toString();

      final rawTips = (data["miniTutorials"] as List<dynamic>? ?? []);
      final parsedTips = rawTips
          .whereType<Map<String, dynamic>>()
          .toList();

      // Sort by tip_number (nice order)
      parsedTips.sort((a, b) {
        final an = (a["tip_number"] is num) ? (a["tip_number"] as num).toInt() : 0;
        final bn = (b["tip_number"] is num) ? (b["tip_number"] as num).toInt() : 0;
        return an.compareTo(bn);
      });

      setState(() {
        miniTutorialName = name.isEmpty ? "Mini Tutorial :" : name;
        tips = parsedTips;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

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
                          "assets/problem-solving.png",
                          width: 30,
                          height: 30,
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
                        borderRadius: BorderRadius.circular(18),
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
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Image.asset(
                                      "assets/buildingbox.png",
                                      height: 130,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 130,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(14),
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

                                // right mini tutorial box (DYNAMIC)
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                    decoration: BoxDecoration(
                                      color: innerBoxBg,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: innerBoxBorder,
                                        width: 1.2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x1E000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: _miniTutorialContent(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // ===== Second section box (Or:) =====
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: innerBoxBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: innerBoxBorder,
                                  width: 1.1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
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
                                      color: bodyBlack,
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
                              "assets/playgames.png",
                              height: 115,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                height: 115,
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

                            const SizedBox(height: 12),

                            Center(
                              child: _PrimaryButton(
                                label: "Continue",
                                onTap: () {
                                   Navigator.pushNamed(
                                    context,
                                    '/problemSolvingQuiz1',
                                    arguments: {'lessonId': widget.lessonId},
                                  );
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
      bottomNavigationBar: const MainNavBar(currentIndex: 3),
    );
  }

  Widget _miniTutorialContent() {
    if (loading) {
      return const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mini Tutorial :",
            style: TextStyle(
              color: titleBrown,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            style: const TextStyle(
              color: bodyBlack,
              fontSize: 9.6,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _PrimaryButton(
            label: "Retry",
            onTap: _loadLesson,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          miniTutorialName,
          style: const TextStyle(
            color: titleBrown,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        if (tips.isEmpty)
          const Text(
            "No mini tutorials available.",
            style: TextStyle(
              color: bodyBlack,
              fontSize: 9.6,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          ...tips.map((t) {
            final content = (t["tip_content"] ?? "").toString().trim();
            if (content.isEmpty) return const SizedBox.shrink();
            return _MiniBullet(content);
          }),
      ],
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
            color: _ProblemSolvingMiniTutorialPageState.circleBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: _ProblemSolvingMiniTutorialPageState.circleBorder,
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
            color: _ProblemSolvingMiniTutorialPageState.circleIcon,
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
              color: _ProblemSolvingMiniTutorialPageState.bodyBlack,
              fontSize: 10.5,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _ProblemSolvingMiniTutorialPageState.bodyBlack,
                fontSize: 9.6,
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
              color: _ProblemSolvingMiniTutorialPageState.bodyBlack,
              fontSize: 10.5,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _ProblemSolvingMiniTutorialPageState.bodyBlack,
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
          height: 30,
          width: 86,
          decoration: BoxDecoration(
            color: _ProblemSolvingMiniTutorialPageState.btnBg,
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
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
