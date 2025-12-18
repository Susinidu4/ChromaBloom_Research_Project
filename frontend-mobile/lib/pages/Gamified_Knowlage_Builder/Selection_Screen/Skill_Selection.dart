import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class SkillSelectionPage extends StatelessWidget {
  const SkillSelectionPage({super.key});

  static const Color pageBg = Color(0xFFF5ECEC);

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: LearnContent(
                  onTapDrawing: () =>
                      Navigator.pushNamed(context, '/drawingTutorial'),
                  onTapProblemSolving: () =>
                      Navigator.pushNamed(context, '/problemSolvingTutorial'),
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

/* ===================== BODY CONTENT ===================== */

class LearnContent extends StatelessWidget {
  const LearnContent({
    super.key,
    required this.onTapDrawing,
    required this.onTapProblemSolving,
  });

  final VoidCallback onTapDrawing;
  final VoidCallback onTapProblemSolving;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const SizedBox(height: 6),

        // ---- Illustration + speech bubble ----
        SizedBox(
          height: 360,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 26,
                right: 72,
                child: _SpeechBubble(
                  maxWidth: w * 0.60,
                  text: "What would you like to\nLearn ?",
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  "assets/GSelection.png",
                  height: 290,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        _LearnTile(
          width: w * 0.88,
          title: "Drawing Tutorial",
          iconAsset: "assets/drawing_palette.png",
          fallbackIcon: Icons.palette_rounded,
          onTap: onTapDrawing,
        ),

        const SizedBox(height: 16),

        _LearnTile(
          width: w * 0.88,
          title: "Problem Solving Tutorial",
          iconAsset: "assets/problem-solving.png",
          fallbackIcon: Icons.psychology_alt_rounded,
          onTap: onTapProblemSolving,
        ),

        const SizedBox(height: 34),
      ],
    );
  }
}

/* ===================== TILE ===================== */

class _LearnTile extends StatelessWidget {
  const _LearnTile({
    required this.width,
    required this.title,
    required this.iconAsset,
    required this.fallbackIcon,
    required this.onTap,
  });

  final double width;
  final String title;
  final String iconAsset;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  static const Color cardBg = Color(0xFFEADCCB);
  static const Color border = Color(0xFFDCC9B6);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: width,
            height: 74,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 6),
                  color: Color(0x1F000000),
                ),
              ],
            ),
            child: Row(
              children: [
                // icon container (like screenshot)
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6EFE7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE6D6C8)),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    iconAsset,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      fallbackIcon,
                      size: 28,
                      color: const Color(0xFF6A6A6A),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA07E6A), // light brown like screenshot
                    ),
                  ),
                ),

                // balance right side so text stays centered
                const SizedBox(width: 46),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== SPEECH BUBBLE ===================== */

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.text,
    required this.maxWidth,
  });

  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F2E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD8C6B4), width: 1.1),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 6),
                color: Color(0x1A000000),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB0896E),
              height: 1.15,
            ),
          ),
        ),
        Positioned(
          bottom: -13,
          left: 26,
          child: CustomPaint(
            size: const Size(22, 14),
            painter: _BubbleTailPainter(
              fill: const Color(0xFFF8F2E8),
              stroke: const Color(0xFFD8C6B4),
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter({required this.fill, required this.stroke});
  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width * 0.3, size.height)
      ..close();

    final paintFill = Paint()..color = fill;
    final paintStroke = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
