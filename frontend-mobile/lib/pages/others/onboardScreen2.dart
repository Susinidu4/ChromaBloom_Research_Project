import 'package:flutter/material.dart';

class OnboardScreen2 extends StatelessWidget {
  const OnboardScreen2({super.key});

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
            // White curved wave background (same pattern)
            Positioned.fill(
              child: CustomPaint(
                painter: _TopWavePainter(waveColor: Colors.white),
              ),
            ),

            // Family image (center-top) - onboard 2 image
            Positioned(
              top: h * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: w * 0.65,
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.asset(
                      "assets/onboard_2.png",
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text(
                          "Missing asset:\nassets/onboard_2.png",
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

            // Bottom card area
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
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
                      "Why Choose ChromaBloom ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF3E8E8),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Support your child’s growth with\n"
                      "adaptive routines, reduce caregiver\n"
                      "stress, and celebrate progress\n"
                      "together\n"
                      "All in one place.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF3E8E8),
                        fontSize: 16,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),

                    const _DotsIndicator(
                      count: 3,
                      activeIndex: 1, // ✅ second dot active
                      activeColor: Color(0xFFD3E7EE),
                      inactiveColor: Color(0xFF1D2B34),
                    ),

                    const SizedBox(height: 26),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/get_started');
                          },
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: Color(0xFFF3E8E8),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/onboard3');
                          },
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD3E7EE),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.20),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
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

// ---------- Dots ----------
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

// ---------- Painter (same curve + soft inner shadow) ----------
class _TopWavePainter extends CustomPainter {
  _TopWavePainter({required this.waveColor});
  final Color waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    // -----------------------
    // 1) White area (wave)
    // Dip on left -> rise on right (CUBIC)
    // -----------------------
    final wavePath = Path()
      ..moveTo(0, size.height * 0.26) // start point (left)
      ..cubicTo(
        size.width * 0.20, size.height * 0.30, // control 1 (dip DOWN)
        size.width * 0.50, size.height * 0.001, // control 2 (rise UP)
        size.width,        size.height * 0.12, // end point (right)
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // draw white
    canvas.drawPath(wavePath, Paint()..color = waveColor);

    // -----------------------
    // 2) Shadow UNDER the curve, inside white area (figma style)
    // -----------------------
    canvas.save();
    canvas.clipPath(wavePath);

    final curveOnly = Path()
      ..moveTo(0, size.height * 0.26)
      ..cubicTo(
        size.width * 0.20, size.height * 0.30, // control 1 (dip DOWN)
        size.width * 0.50, size.height * 0.001, // control 2 (rise UP)
        size.width,        size.height * 0.12,
      );

    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..color = Colors.black.withOpacity(0.90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    // push shadow slightly down so it appears below the curve
    canvas.translate(0, 8);
    canvas.drawPath(curveOnly, shadowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

