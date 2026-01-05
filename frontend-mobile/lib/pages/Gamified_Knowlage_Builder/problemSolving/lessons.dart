import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class ProblemSolvingUnit1Page extends StatelessWidget {
  ProblemSolvingUnit1Page({super.key}); // non-const while iterating

  static const Color pageBg = Color(0xFFF3E8E8);

  // Card palette (same style as your sample)
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color leftShade = Color(0xFFDFC7A7);
  static const Color titleColor = Color(0xFFA07E6A);
  static const Color descColor = Color(0xFFBD9A6B);

  // Top row
  static const Color topRowBlue = Color(0xFF386884);
  static const Color actionBtnBg = Color(0xFFF8F2E8);
  static const Color actionBtnBorder = Color(0xFFD8C6B4);
  static const Color actionIcon = Color(0xFFB0896E);

  final lessons = <_LessonItem>[
    const _LessonItem(
      title: "Match the Similar Objects",
      desc: "Help your child match two objects that belong together.",
      progress: 0.55,
    ),
    const _LessonItem(
      title: "Spot the Difference",
      desc: "Find the small differences between two pictures to boost attention.",
      progress: 0.30,
    ),
    const _LessonItem(
      title: "Sorting by Category",
      desc: "Sort objects into groups like food, animals, or clothes.",
      progress: 0.15,
    ),
    const _LessonItem(
      title: "What Happens Next?",
      desc: "Arrange picture cards to understand daily routines.",
      progress: 0.05,
    ),
    const _LessonItem(
      title: "Find the Missing Piece",
      desc: "Choose the missing shape or picture that completes the puzzle.",
      progress: 0.00,
    ),
  ];

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

            // ===== Top row: icon + title + plus =====
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Row(
                children: [
                  Image.asset(
                    "assets/problem-solving.png", 
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.psychology_alt_rounded,
                      size: 22,
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
                    icon: Icons.add,
                    onTap: () {
                      Navigator.pushNamed(context, '/skillSelection');
                    },
                  ),
                ],
              ),
            ),

            // ===== List =====
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                itemCount: lessons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = lessons[index];
                  return _LessonCard(
                    title: item.title,
                    desc: item.desc,
                    progress: item.progress,
                    onTap: () {
                      // TODO: open lesson page
                      // Navigator.pushNamed(context, '/problemLesson', arguments: item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 2),
    );
  }
}

/* ===================== DATA ===================== */

class _LessonItem {
  final String title;
  final String desc;
  final double progress;
  const _LessonItem({
    required this.title,
    required this.desc,
    required this.progress,
  });
}

/* ===================== TOP RIGHT + BUTTON ===================== */

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  static const Color bg = ProblemSolvingUnit1Page.actionBtnBg;
  static const Color border = ProblemSolvingUnit1Page.actionBtnBorder;
  static const Color iconColor = ProblemSolvingUnit1Page.actionIcon;

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
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

/* ===================== LESSON CARD (DOTS INSIDE LEFT STRIP) ===================== */

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.title,
    required this.desc,
    required this.onTap,
    this.progress = 0.0,
  });

  final String title;
  final String desc;
  final VoidCallback onTap;
  final double progress;

  static const Color cardBg = ProblemSolvingUnit1Page.cardBg;
  static const Color leftShade = ProblemSolvingUnit1Page.leftShade;
  static const Color titleColor = ProblemSolvingUnit1Page.titleColor;
  static const Color descColor = ProblemSolvingUnit1Page.descColor;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3A000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // LEFT STRIP WITH DOTS INSIDE
              Container(
                width: 18,
                decoration: const BoxDecoration(
                  color: leftShade,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(),
                    SizedBox(height: 4),
                    _Dot(),
                    SizedBox(height: 4),
                    _Dot(),
                  ],
                ),
              ),

              // TEXT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.2,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.6,
                          fontWeight: FontWeight.w500,
                          color: descColor,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // RIGHT PROGRESS BAR
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ProgressPill(progress: p),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================== DOT ===================== */

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3.8,
      height: 3.8,
      decoration: const BoxDecoration(
        color: Color(0xFFB89A76),
        shape: BoxShape.circle,
      ),
    );
  }
}

/* ===================== PROGRESS BAR ===================== */

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({required this.progress});
  final double progress;

  static const Color track = Color(0xFFD8C6B4);
  static const Color fill = Color(0xFFB89A76);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(color: fill),
            ),
          ],
        ),
      ),
    );
  }
}
