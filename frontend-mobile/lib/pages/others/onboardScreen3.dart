import 'package:flutter/material.dart';

class OnboardScreen3 extends StatelessWidget {
  const OnboardScreen3({super.key});

  static const Color bgBlue = Color(0xFF386884);
  static const Color cardBlue = Color(0xFF386884);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgBlue,
      body: SafeArea(
        child: Stack(
          children: [
            // White curved wave background + inner shadow
            Positioned.fill(
              child: CustomPaint(
                painter: _TopWavePainter(waveColor: Colors.white),
              ),
            ),

            // Family image (center)
            Positioned(
              top: h * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: w * 0.65,
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: Image.asset(
                      "assets/onboard_3.png", // ✅ use your 3rd image
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text(
                          "Missing asset:\nassets/onboard_3.png",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom card
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                decoration: const BoxDecoration(
                  color: cardBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      "How it works...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF3E8E8),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Set up your child’s daily routines, add\n"
                      "visual tasks with audio, and let our\n"
                      "app guide them step by step.\n\n"
                      "Caregivers and therapists can easily\n"
                      "track and update progress.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF3E8E8),
                        fontSize: 16,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // dots: 3rd screen => activeIndex = 2
                    const _DotsIndicator(
                      count: 3,
                      activeIndex: 2,
                      activeColor: Color(0xFFD3E7EE),
                      inactiveColor: Color(0xFF1D2B34),
                    ),

                    const SizedBox(height: 26),

                    // Skip + Next
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // ⬅️ move to right
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/get_started',
                            );
                          },
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD3E7EE),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.black,
                              size: 34,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.activeIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _TopWavePainter extends CustomPainter {
  _TopWavePainter({required this.waveColor});
  final Color waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    // ✅ Onboard 3 curve: high-left -> slopes down to right (like your screenshot)
    final wavePath = Path()
      ..moveTo(0, size.height * 0.12)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.013, // lift a bit on left
        size.width * 0.50,
        size.height * 0.30, // push down mid-right
        size.width,
        size.height * 0.26, // end lower on right
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // 1) White fill
    canvas.drawPath(wavePath, Paint()..color = waveColor);

    // 2) Inner shadow under the curve (inside white)
    canvas.save();
    canvas.clipPath(wavePath);

    final curveOnly = Path()
      ..moveTo(0, size.height * 0.12)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.013,
        size.width * 0.50,
        size.height * 0.30,
        size.width,
        size.height * 0.26,
      );

    final innerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..color = Colors.black.withOpacity(0.90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.translate(0, 8);
    canvas.drawPath(curveOnly, innerShadowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
